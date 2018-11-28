import matplotlib.pyplot as plt
import numpy as np
import requests


class Prometheus:
    def __init__(self, host) -> None:
        self.host = host

    def plot_metric(self, query: str, start_time: int, end_time: int, step_seconds: int) -> None:
        for values in self._get_values_for_query(query, start_time, end_time, step_seconds):
            self._plot_tuple_list(values)

    def _get_values_for_query(self, query, start_time, end_time, step_seconds):
        response = self._get_series(query, start_time, end_time, step_seconds)
        return self._get_values_from_metric(response)

    def _get_series(self, query, start_time, end_time, step_seconds):
        params = {"start": start_time, "end": end_time, "query": query, "step": step_seconds}
        response = requests.get(self._get_query_range_endpoint(), params=params)
        if response.status_code != 200:
            raise RuntimeError("Bad Response: ", response.json())
        return response.json()["data"]["result"]

    def _get_query_range_endpoint(self) -> str:
        return f"{self.host}/api/v1/query_range"

    def _plot_tuple_list(self, xy):
        x, y = self._tuple_list_to_two_lists(xy)
        y_fit = self._get_poly_fit(x, y)
        plt.plot(x, y, x, y_fit)
        plt.show()

    @staticmethod
    def _get_values_from_metric(metrics):
        yield from [[(x[0], float(x[1])) for x in met["values"]] for met in metrics]

    @staticmethod
    def _tuple_list_to_two_lists(xy):
        return list(zip(*xy))

    @staticmethod
    def _get_poly_fit(x, y, degree=1):
        fit_poly = np.polyfit(x, y, degree)
        fit_function = np.poly1d(fit_poly)
        return fit_function(x)
