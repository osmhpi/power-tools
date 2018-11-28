import requests

class Prometheus:

    def __init__(self, host):
        self.host = host

    def get_series(self, query: str, start: int, end: int):
        params = {start: start, end: end, query: query}
        response = requests.get(self._get_query_range_endpoint(), params=params)
        return response

    def _get_query_range_endpoint(self):
        return f'{self.host}/api/v1/query_range'
