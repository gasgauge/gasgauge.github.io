import random
import os


class Fuzzer():

    # initialize all class variables
    def __init__(self, gas_limit, inputs, contract_folder, output_file_path,
                 test_path, max_count=5):

        self.inputs = inputs
        action_list = []
        observation_list = []
        fuzz_types = []
        for inp in inputs:
            ac, ob, f = self.find_size(inp[1])
            action_list.append(ac)
            observation_list.append(ob)
            fuzz_types.append(f)
        self.contract_folder = contract_folder
        self.test_path = test_path
        self.output_file_path = output_file_path
        self.action_size = action_list
        self.observation_size = observation_list
        self.fuzz_types = fuzz_types
        self.action_space = range(sum(action_list))

        self.count = 0
        self.max_count = max_count
        self.observation = [0] * sum(self.observation_size)
        self.gas_limit = gas_limit
        self.revert = 0
        self.reset()

    def getReward(self, gasLeft):
        reward = (self.gas_limit - gasLeft) / self.gas_limit
        if gasLeft < 0:
            reward = gasLeft
        return reward

    # main function : 1. modify the input based on the action from the agent
    #                   2. compile the contract based the new inputs
    #                   3. update the reward and observation
    def step(self, action, action_type=0):

        assert action in self.action_space

        # bit flip
        if action_type == 0:
            if self.observation[action] == 1:
                self.observation[action] = 0
            else:
                self.observation[action] = 1

        # byte flip
        if action_type == 1:
            if sum(self.observation_size) < 9:
                for i in range(sum(self.observation_size)):
                    if self.observation[i] == 1:
                        self.observation[i] = 0
                    else:
                        self.observation[i] = 1
            else:
                for i in range(8):
                    bit = (i + action) % sum(self.observation_size)
                    if self.observation[bit] == 1:
                        self.observation[bit] = 0
                    else:
                        self.observation[bit] = 1

        # byte shuffle
        if action_type == 2:
            if self.observation[action] == 1:
                self.observation[action] = 0
            else:
                self.observation[action] = 1
            substring = []
            if sum(self.observation_size) < 9:
                for i in range(sum(self.observation_size)):
                    substring.append(self.observation[i])
                random.shuffle(substring)
                for i in range(len(substring)):
                    self.observation[i] = substring[i]
            else:
                for i in range(8):
                    bit = (i + action) % sum(self.observation_size)
                    substring.append(self.observation[bit])
                random.shuffle(substring)
                for i in range(8):
                    bit = (i + action) % sum(self.observation_size)
                    self.observation[bit] = substring[i]

        new_inputs = []
        counter = 0
        for i in range(len(self.observation_size)):
            binary_in = self.observation[counter:self.observation_size[i] + counter]
            new_input = int("".join(str(x) for x in binary_in), 2)
            new_inputs.append(new_input)
            counter += self.observation_size[i]

        self.modifyTest(new_inputs)
        command = "cd " + self.contract_folder + " ;truffle" + " test 2>&1 | tee " + self.output_file_path
        os.system(command)
        gas_left = self.getOutput()
        reward = self.getReward(gas_left)
        self.count += 1
        done = False
        if reward == 1 or self.count >= self.max_count or (-1 > gas_left > -10):
            done = True
        if gas_left == -10:
            self.revert = new_inputs

        # return self.observation, reward, done, {"count": self.count, "gasLeft": gas_left}
        return self.observation, reward, done, self.count, gas_left, new_inputs, self.revert

    def reset(self):
        self.count = 0
        self.observation = [0] * sum(self.observation_size)
        return self.observation

    # This function modifies the test file so we can try differnt inputs
    def modifyTest(self, new_inputs):

        # print("file_to_open is:",filePath)
        unsorted = open(self.test_path, "r")
        list = []

        flag = False
        if unsorted.mode == 'r':
            for line in unsorted:
                new_line = line
                for i in range(len(self.inputs)):
                    key_word = self.inputs[i][1] + ' ' + self.inputs[i][0]
                    if self.fuzz_types[i] == "size":
                        key_word = self.inputs[i][1] + ' memory ' + self.inputs[i][0]
                    if key_word in line:
                        t = self.inputs[i][1]
                        if self.fuzz_types[i] == "value":
                            new_line = '\t\t' + key_word + ' = ' + str(new_inputs[i]) + ";"
                            if "byte" in t:
                                t_size = 8
                                if t in ['byte', 'bytes']:
                                    t_size = 8
                                else:
                                    t_size = int(t[t.index("bytes") + 5:]) * 2
                                hex_input = str(hex(new_inputs[i]))[2:]
                                while len(hex_input) < t_size:
                                    hex_input = '0' + hex_input
                                hex_input = "0x" + hex_input

                                new_line = '\t\t' + key_word + ' = ' + hex_input + ";"
                        elif self.fuzz_types[i] == "size":
                            input_string = ""
                            if "[]" in t:
                                new_line = line[:line.index("(")]
                                new_line += "(" + str(new_inputs[i]) + ") ;"
                            elif "string" in t:
                                new_line = line[:line.index("=") + 1]
                                new_s = "\""
                                for i in range(new_inputs[i]):
                                    new_s += "a"
                                new_s += "\" ;"
                                new_line += new_s

                list.append(new_line.rstrip("\n"))

        unsorted.close()
        self.writeToFile(list)

    # writes a text in a file
    def writeToFile(self, test_text):
        f = open(self.test_path, "w+")
        for i in test_text:
            f.write(i + "\n")
        f.close()

    # This function gets the output of the contract and calculates the gas usuage
    def getOutput(self):
        # print("filePath in getOutput:",filePath)
        f = open(self.contract_folder + '/' +self.output_file_path, "r")
        output = -1
        "Error: The remaining gas! (Tested: 6263214, Against: 0)"
        if f.mode == 'r':
            for line in f:
                if 'he remaining gas' in line:
                    output = int(line[line.index("Tested:") + 8: line.index(",")])
                    break
                elif 'Reason given:' in line or "sender doesn't have enough funds" in line:
                    output = -2
                    break
                elif "Error: Returned error: VM Exception while processing transaction: revert" in line:
                    output = -10  # here may need to be improved.
                    break
                elif "out of gas" in line:
                    output = 0
                    break
                elif "instance of an abstract" in line:
                    output = -4
                    break
                elif "Invalid implicit conversion from" in line or 'not yet implemented' in line or 'TypeError' in line or 'Error: while migrating'in line or 'not implemented here' in line:
                    output = -5
                    break
                elif "not found or not visible" in line:
                    output = -6
                    break
                elif "Compilation failed" in line:
                    output = -3


        f.close()
        return output

    def find_size(self, value_type):
        action_space_size = 0
        observation_space_size = 0
        fuzz_type = "NA"

        if "[" in value_type and "]" in value_type:
            val_size = 256
            fuzz_type = "size"
            if "[]" not in value_type:
                val_size = int(value_type[value_type.index("[") + 1: value_type.index("]")])
            observation_space_size = val_size
            action_space_size = val_size
            # a_space, o_space, f_type = find_size(val_type)
            # action_space_size = val_size * a_space

        elif "int" in value_type:
            if value_type == "int" or value_type == "uint":
                action_space_size = 256
            else:
                action_space_size = int(value_type[value_type.index("int") + 3:])
            observation_space_size = action_space_size
            fuzz_type = "value"

        elif "address" in value_type:
            action_space_size = 20 * 8
            observation_space_size = action_space_size
        elif "byte" in value_type:
            if value_type in ["byte", "bytes"]:
                action_space_size = 8
            else:
                action_space_size = 8 * int(value_type[value_type.index("bytes") + 5:])
            observation_space_size = action_space_size
            fuzz_type = "value"
        elif "string" in value_type:
            action_space_size = 256
            observation_space_size = action_space_size
        elif "bool" in value_type:
            action_space_size = 1
            observation_space_size = action_space_size

        return action_space_size, observation_space_size, fuzz_type


