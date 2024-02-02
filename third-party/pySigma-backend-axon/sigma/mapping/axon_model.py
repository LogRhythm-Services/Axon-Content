import json
from typing import Optional, List


class LRSearchRequest:
    def __init__(self,
                 tenantId: str,
                 computedTypes: Optional[List[str]] = None,
                 filter: Optional[str] = None,
                 aggregations: Optional['AggregationBatchRequest'] = None,
                 searchId: Optional[str] = None,
                 ephemeralFilter: Optional[str] = None,
                 taskId: Optional[str] = None,
                 newSearch: Optional[bool] = None,
                 time: Optional['Time'] = None,
                 pageRequest: Optional['SeekPageRequest'] = None):
        self.tenantId = tenantId
        self.computedTypes = computedTypes
        self.filter = filter
        self.aggregations = aggregations
        self.searchId = searchId
        self.ephemeralFilter = ephemeralFilter
        self.taskId = taskId
        self.newSearch = newSearch
        self.time = time
        self.pageRequest = pageRequest

    def to_dict(self):
        """Convert the object to a dictionary, filtering out None values and converting nested objects."""
        result = {}
        for key, value in self.__dict__.items():
            if value is not None:
                if hasattr(value, 'to_dict'):
                    # If the attribute is an object with a to_dict method, call that method
                    result[key] = value.to_dict()
                else:
                    result[key] = value
        return result

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class AggregationBatchRequest:
    def __init__(self,
                 aggregation_requests: List['AggregationRequest']):
        self.aggregation_requests = aggregation_requests

    def to_dict(self):
        """Convert the object to a dictionary."""
        return self.__dict__

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class Time:
    def __init__(self,
                 time_box_enum: Optional[str] = None,
                 start_time: Optional[str] = None,
                 end_time: Optional[str] = None,
                 field: Optional[str] = None,
                 lr_date_time: Optional[str] = None):
        self.timeBoxEnum = time_box_enum
        self.startTime = start_time
        self.endTime = end_time
        self.field = field
        self.lrDateTime = lr_date_time

    def to_dict(self):
        """Convert the object to a dictionary, filtering out None values and converting nested objects."""
        result = {}
        for key, value in self.__dict__.items():
            if value is not None:
                if hasattr(value, 'to_dict'):
                    # If the attribute is an object with a to_dict method, call that method
                    result[key] = value.to_dict()
                else:
                    result[key] = value
        return result

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class SeekPageRequest:
    def __init__(self,
                 limit: Optional[int] = None,
                 sort: Optional['Sort'] = None,
                 after_id: Optional[str] = None):
        self.limit = limit
        self.sort = sort
        self.after_id = after_id

    def to_dict(self):
        """Convert the object to a dictionary, filtering out None values and converting nested objects."""
        result = {}
        for key, value in self.__dict__.items():
            if value is not None:
                if hasattr(value, 'to_dict'):
                    # If the attribute is an object with a to_dict method, call that method
                    result[key] = value.to_dict()
                else:
                    result[key] = value
        return result

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class AggregationRequest:
    def __init__(self,
                 aggregation_type: str,
                 field: str,
                 bucket_order: Optional[str] = None,
                 bucket_limit: Optional[int] = None,
                 bucket_interval: Optional[str] = None,
                 number_of_intervals: Optional[int] = None,
                 lr_date_time_range: Optional[str] = None,
                 sub_aggregations: Optional[List['AggregationRequest']] = None,
                 bucket_start: Optional[str] = None,
                 bucket_end: Optional[str] = None,
                 bucket_fields: Optional[List[str]] = None):
        self.aggregation_type = aggregation_type
        self.field = field
        self.bucket_order = bucket_order
        self.bucket_limit = bucket_limit
        self.bucket_interval = bucket_interval
        self.number_of_intervals = number_of_intervals
        self.lr_date_time_range = lr_date_time_range
        self.sub_aggregations = sub_aggregations
        self.bucket_start = bucket_start
        self.bucket_end = bucket_end
        self.bucket_fields = bucket_fields

    def to_dict(self):
        """Convert the object to a dictionary, filtering out None values and converting nested objects."""
        result = {}
        for key, value in self.__dict__.items():
            if value is not None:
                if hasattr(value, 'to_dict'):
                    # If the attribute is an object with a to_dict method, call that method
                    result[key] = value.to_dict()
                else:
                    result[key] = value
        return result

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class SortField:
    def __init__(self,
                 field_name: str,
                 ascending: Optional[bool] = True):
        self.field_name = field_name
        self.ascending = ascending

    def to_dict(self):
        """Convert the object to a dictionary."""
        return self.__dict__

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)


class Sort:
    def __init__(self,
                 sort_fields: List[SortField]):
        self.sort_fields = sort_fields

    def to_dict(self):
        """Convert the object to a dictionary."""
        return {
            "sort_fields": [field.to_dict() for field in self.sort_fields]
        }

    def __str__(self):
        return json.dumps(self.to_dict(), indent=4)
