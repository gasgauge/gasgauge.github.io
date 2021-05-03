from env import Environment
from numpy import random


class Agent():
    def __init__(self, setup, initial_action=0, max_episodes=20, max_action=5000):
        self.setup = setup
        self.max_episodes = max_episodes
        self.initial_action = initial_action
        self.max_action = max_action

    """
        Observations:
        0 - No guess yet submitted (only after reset)
        1 - Guess is the target
        2 - Guess is higher than the target
        3 - Guess is lower than the target
        4 - Threshold is over max
        5 - Changing the guess does not make a difference
        6 - Reached the maximum number of epochs
        7 - Was not able to find_loops the threshold
        8 - an error that cannot be handled
    """
    def normal_loop_agent(self):
        env = Environment(self.setup, self.max_action, self.max_episodes)
        env.reset()
        lower_bound = 0
        upper_bound = self.max_action + 1
        guess = self.initial_action
        info = []
        for episode in range(self.max_episodes):
            if guess > self.max_action:
                guess = self.max_action
            observation, done, info = env.step(guess)
            if observation == 2:
                upper_bound = guess - 1
            elif observation == 3:
                lower_bound = guess + 1
            else:
                return [observation, info, episode]
            if upper_bound < lower_bound:
                return [7, info, episode]

            guess = int((upper_bound + lower_bound) / 2)
            print(guess)
        return [6, info, self.max_episodes]

    def BF_agent(self):
        env = Environment(self.setup, self.initial_action)
        env.reset()
        guess = self.initial_action
        for episode in range(self.max_episodes):
            observation, done, info = env.step(guess)
            if observation == 1 or observation == 4:
                return [observation, info, episode]
            if observation == 2:
                guess -= 2
            if observation == 3:
                guess += 2
        return [-1, 0, self.max_episodes]

    def optimized_random_agent(self):
        env = Environment(self.setup, self.initial_action)
        env.reset()
        lower_bound = 0
        upper_bound = env.action_space.n
        for episode in range(self.max_episodes):
            if upper_bound < lower_bound:
                return [-1, info, episode]
            guess = random.randint(lower_bound, upper_bound)
            observation, done, info = env.step(guess)
            if observation == 1 or observation == 4:
                return [observation, info, episode]
            if observation == 2:
                upper_bound = guess - 1
            if observation == 3:
                lower_bound = guess + 1
        return [-1, 0, self.max_episodes]
