from typing import Dict
import numpy as np
from numpy.lib.scimath import log2, power

import csv

# Array of user amount to try out
USER_AMOUNTS = np.arange(10, 1001, step=10)


def generate_sort_execution_times(
    overhead: int = 1,
    iterations: int = 10,
    user_amounts: np.ndarray = USER_AMOUNTS,
) -> Dict[int, np.ndarray]:
    """
    This generates data for each entry in the population size list for a desired amount of iterations.

    This function assumes an sorting function with worst case execution time of O(n^2), average time of O(nlog(n))
    and best case time of O(nlog(n))

    :param overhead: the overhead for the sort implementation
    :param iterations: the amount of iterations per population size
    :param users_amounts: the population of users that data should be generated for
    """

    result = {user_amount: None for user_amount in user_amounts}

    for user_amount in user_amounts:
        # Standard deviation
        sd = 1

        def map_execution_time(distribution_location: int):
            # Best and average case are O(log(nlog(n)))
            # Worst case is O(n^2)
            # If the result are outside of 3 standard deviations on the positive side, use worst case
            if distribution_location > (3 * sd):
                exec_time = power(user_amount, 2)
            else:
                exec_time = log2(user_amount)
            # Get a random positive value between a three quarters of the execution time and the execution time
            return np.random.uniform(exec_time * 0.75, exec_time) * overhead

        normal_distribution = np.random.normal(0.0, sd, iterations)
        user_amount_result = np.array(
            list(map(map_execution_time, normal_distribution))
        )
        result[user_amount] = user_amount_result

    return result


def create_data_file(
    file_str: str,
    overhead: int = 1,
    iterations: int = 10,
    user_amounts: np.ndarray = USER_AMOUNTS,
):
    data = generate_sort_execution_times(
        iterations=iterations, overhead=overhead, user_amounts=user_amounts
    )
    with open(file_str, "w") as file:
        writer = csv.writer(file)
        columns = list(map(lambda i: "Iteration {}".format(i + 1), range(iterations)))
        writer.writerow(["User amount"] + columns)
        for user_amount, result in data.items():
            writer.writerow(
                np.concatenate([np.array([user_amount], dtype=int), result])
            )


if __name__ == "__main__":
    create_data_file("javascript-data.csv", overhead=1.5)
    create_data_file("webasm-data.csv", overhead=1)
