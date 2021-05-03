from multiprocessing.pool import ThreadPool
import time


class Environment:

    def __init__(self, Setup, max_action, max_epochs):
        self.Setup = Setup
        self.max_action = max_action
        self.action_space = range(self.max_action + 2)
        """
        Observations:
        0 - No guess yet submitted (only after reset)
        1 - Guess is the target
        2 - Guess is higher than the target
        3 - Guess is lower than the target
        4 - Threshold is over max
        5 - Changing the guess does not make a difference
        6 - Reached maximum number of epochs
        8 - error
        """
        self.observation_space = range(7)
        self.guess_count = 0
        self.max_epochs = max_epochs
        self.observation = 0
        self.reset()

    def step(self, action):
        assert action in self.action_space
        assert action + 1 in self.action_space
        assert action - 1 in self.action_space
        gas_limit = self.Setup[0].env_gas_limit
        pool = ThreadPool(processes=1)
        async_result = pool.apply_async(self.Setup[1].get_gas_left, [action - 1])
        time.sleep(1)
        pool2 = ThreadPool(processes=1)
        async_result2 = pool2.apply_async(self.Setup[2].get_gas_left, [action + 1])
        time.sleep(1)
        gas_left = self.Setup[0].get_gas_left(action)
        reward = 0
        previous_reward = 0
        threshold = -1
        done = False
        new_gas_left = async_result.get()
        new_gas_left2 = async_result2.get()
        if gas_left < -2:
            if new_gas_left < -2 and new_gas_left2 < -2:
                self.observation = 8
                if gas_left == -5:
                    self.observation = 9
                done = True

        elif gas_left < 0:
            if new_gas_left >= 0:
                reward = 1
                threshold = action - 1
                self.observation = 1
                done = True
            else:
                self.observation = 2

        else:
            if new_gas_left == new_gas_left2 and new_gas_left == gas_left and gas_left > 0:
                self.observation = 5
                done = True
            new_gas_left = new_gas_left2
            if new_gas_left < 0:
                reward = 1
                threshold = action
                self.observation = 1
                done = True
            else:
                self.observation = 3
                reward = 1 - (gas_left / gas_limit)
                if action >= self.max_action:
                    self.observation = 4
                    done = True
                    threshold = action

        self.guess_count += 1
        if self.guess_count >= self.max_epochs and not done:
            self.observation = 6
            done = True
        if previous_reward == reward and 0 < reward < 1:
            self.observation = 5
            done = True

        return self.observation, done, {"Threshold": threshold, "gas_left": gas_left, "reward": reward,
                                        "last_action": action}

    def reset(self):
        self.guess_count = 0
        self.observation = 0
        return self.observation
