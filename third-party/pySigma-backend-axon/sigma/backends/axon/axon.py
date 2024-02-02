import re
import sigma

from typing import ClassVar, Dict, Tuple, Pattern, Optional, List, Callable

from sigma.conditions import ConditionItem, ConditionAND, ConditionOR, ConditionNOT
from sigma.conversion.base import TextQueryBackend
from sigma.conversion.state import ConversionState
from sigma.processing.pipeline import ProcessingPipeline
from sigma.pipelines.axon import axon_pipeline
from sigma.rule import SigmaRule
from sigma.types import SigmaCompareExpression
from sigma.mapping.axon_model import *


class AxonBackend(TextQueryBackend):
    """Axon backend."""
    name : ClassVar[str] = "Axon backend"
    formats : Dict[str, str] = {
        "default": "Plain Axon queries",
        "axon_api": "LogRhythm API Payload"
    }
    requires_pipeline: ClassVar[bool] = False
    processing_pipeline: ProcessingPipeline
    backend_processing_pipeline: ClassVar[ProcessingPipeline] = axon_pipeline()

    precedence: ClassVar[Tuple[ConditionItem, ConditionItem, ConditionItem]] = (ConditionNOT, ConditionAND, ConditionOR)
    group_expression: ClassVar[str] = "({expr})"

    token_separator: str = " "
    or_token: ClassVar[str] = "OR"
    and_token: ClassVar[str] = "AND"
    not_token: ClassVar[str] = "NOT"
    eq_token: ClassVar[str] = "="

    wildcard_multi: ClassVar[str] = "*"
    wildcard_single: ClassVar[str] = "*"
    bool_values: ClassVar[Dict[bool, str]] = {
        True: "true",
        False: "false",
    }

    # String matching operators. if none is appropriate eq_token is used.
    startswith_expression: ClassVar[str] = '{field} matches "^{value}"'
    endswith_expression: ClassVar[str] = '{field} matches "{value}$"'
    contains_expression: ClassVar[str] = '{field} matches "{value}"'
    wildcard_match_expression: ClassVar[
        str] = '"{field} matches  "{value}"'  # Special expression if wildcards can't be matched with the eq_token operator

    # Regular expressions
    re_expression: ClassVar[str] = '{field} matches "{regex}"'
    re_escape_char: ClassVar[str] = "\\"
    re_escape: ClassVar[Tuple[str]] = ()
    re_escape_escape_char: bool = True
    re_flag_prefix: bool = False

    # Case sensitive string matching expression. String is quoted/escaped like a normal string.
    case_sensitive_match_expression: ClassVar[str] = '{field} matches "{value}"'
    case_sensitive_startswith_expression: ClassVar[str] = '{field} matches "^{value}"'
    case_sensitive_endswith_expression: ClassVar[str] = '{field} matches "{value}$"'
    case_sensitive_contains_expression: ClassVar[str] = '{field} matches "{value}"'

    # CIDR expressions: define CIDR matching if backend has native support. Else pySigma expands
    cidr_expression: ClassVar[Optional[str]] = "{value}"

    # Numeric comparison operators
    compare_op_expression: ClassVar[str] = "{field} {operator} {value}"
    compare_operators: ClassVar[Dict[SigmaCompareExpression.CompareOperators, str]] = {
        SigmaCompareExpression.CompareOperators.LT: "<",
        SigmaCompareExpression.CompareOperators.LTE: "<=",
        SigmaCompareExpression.CompareOperators.GT: ">",
        SigmaCompareExpression.CompareOperators.GTE: ">=",
    }

    # Null/None expressions
    field_null_expression: ClassVar[
        str] = "{field} = Blank"  # Expression for field has null value as format string with {field} placeholder for field name

    # Field value in list
    convert_or_as_in: ClassVar[bool] = False
    convert_and_as_in: ClassVar[bool] = False
    in_expressions_allow_wildcards: ClassVar[bool] = True
    field_in_list_expression: ClassVar[str] = '{field} {op} "{list}"'
    or_in_operator: ClassVar[str] = "matches"
    list_separator: ClassVar[str] = "|"

    # Value not bound to a field
    unbound_value_str_expression: ClassVar[str] = '{value}'
    unbound_value_num_expression: ClassVar[str] = '{value}'
    unbound_value_re_expression: ClassVar[str] = '{value}'

    # Query finalization: appending and concatenating deferred query part
    deferred_start: ClassVar[str] = "\n| "  # String used as separator between main query and deferred parts
    deferred_separator: ClassVar[str] = "\n| "  # String used to join multiple deferred query parts
    deferred_only_query: ClassVar[str] = "*"  # String used as query if final query only contains deferred expression

    # Default Values for Searches.
    tenant_id = "demo"
    limit_search = 10000

    def __init__(self, processing_pipeline: Optional["sigma.processing.pipeline.ProcessingPipeline"] = None,
                 collect_errors: bool = False, start_time: str = "", end_time: str = "", tenant_id: str = "",
                 limit_search: int = 10000, **kwargs):
        super().__init__(processing_pipeline, collect_errors, **kwargs)
        self.end_time = end_time
        self.start_time = start_time
        self.tenant_id = tenant_id
        self.limit_search = limit_search

    def finalize_query_default(self,
                               rule: SigmaRule,
                               query: str,
                               index: int,
                               state: ConversionState) -> str:
        if self.end_time == "" and self.start_time == "":
            return query
        elif self.start_time != "" and self.end_time == "":
            axon_query = f" general_information.standard_message_time={self.start_time}-24h"  # Default Axon search to 24hrs
        elif self.start_time == "" and self.end_time != "":
            axon_query = f" general_information.standard_message_time=now-{self.end_time}"  # Default Axon search starts now
        else:
            axon_query = f" general_information.standard_message_time={self.start_time}-{self.end_time}"
        return query + axon_query

    def finalize_output_default(self, queries: List[str]) -> List[str]:
        return queries

    def finalize_query_axon_api(self,
                                rule: SigmaRule,
                                query: str,
                                index: int,
                                state: ConversionState) -> Dict:
        if self.end_time == "" and self.start_time == "":
            lr_time = Time(lr_date_time="now-24h")
        elif self.start_time != "" and self.end_time == "":
            lr_time = Time(lr_date_time=f"{self.start_time}-24h")
        elif self.start_time == "" and self.end_time != "":
            lr_time = Time(lr_date_time=f"now-{self.end_time}")
        else:
            lr_time = Time(lr_date_time=f"{self.start_time}-{self.end_time}")
        page_request = SeekPageRequest(limit=self.limit_search)
        search_request = LRSearchRequest(
            tenantId=self.tenant_id,
            filter=query,
            pageRequest=page_request,
            time=lr_time
        )
        return search_request.to_dict()

    def finalize_output_axon_api(self, queries: List[Dict]) -> List[Dict]:
        return queries
