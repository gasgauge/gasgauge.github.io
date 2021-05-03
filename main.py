from findloops import FindLoops
from setup import SetUp
from agent import Agent
from fuzzer import Fuzzer

from multiprocessing.pool import ThreadPool
import timeit
import shutil
import random
import string
import glob
import os


def call_cmd(command):
    os.system(command)


def copydir(src, dest, ignore=None):
    if os.path.isdir(src):
        if not os.path.isdir(dest):
            os.makedirs(dest)
        files = os.listdir(src)
        if ignore is not None:
            ignored = ignore(src, files)
        else:
            ignored = set()
        for f in files:
            if f not in ignored:
                copydir(os.path.join(src, f),
                        os.path.join(dest, f),
                        ignore)
    else:
        shutil.copyfile(src, dest)


class Main():
    def __init__(self, contract_path, contract_file, gas_limit, ganache_inputs, output_folder, output_file, agent_output,
                 gas_gauge_dir, new_contract_name, fuzzer_max, solc_use):
        self.contract_path = contract_path
        self.contract_file = contract_file
        self.gas_limit = gas_limit
        self.port1 = ganache_inputs["port1"]
        self.port2 = ganache_inputs["port2"]
        self.port3 = ganache_inputs["port3"]
        self.host = ganache_inputs["host"]
        self.ganache_param = 'ganache-cli'
        for key in ganache_inputs.keys():
            if 'port' not in key:
                self.ganache_param += ' --' + str(key) + ' ' + str(ganache_inputs.get(key))

        self.output_folder = output_folder
        self.output_file = output_file
        self.output_file_temp = self.output_folder + self.output_file
        self.agent_output = self.output_folder + agent_output
        ex = agent_output[agent_output.index('.')]
        agent_output = agent_output[:agent_output.index('.')]
        self.agent_output2 = self.output_folder + agent_output + '_2' + ex
        self.agent_output3 = self.output_folder + agent_output + '_3' + ex
        self.gas_gauge_dir = gas_gauge_dir
        self.new_contract_name = new_contract_name
        self.datatypes = ['int', 'uint', 'address', 'byte', 'string', 'bool']
        self.fuzzer_max = fuzzer_max
        self.solc_use = solc_use

    def run_agent(self, file_name, loop, loop_number, new_runtime_contract, loop_index, c_folder,
                  result,
                  run_time_threshold, observations, contract_info, original_gas, first_it_gas, added_gas_per_it=10):
        newcontractpath = self.gas_gauge_dir + "/" + file_name[
                                                 :file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                           :self.new_contract_name.index(
                                                                                               '.')]
        setup = SetUp(self.contract_path, file_name, self.new_contract_name, newcontractpath, self.port1, self.host, self.gas_limit)
        contract_p = setup.run_all()

        setup.modify_migrations(contract_info)
        setup.set_env_vars(loop, loop_number, self.agent_output, c_folder, self.gas_limit, new_runtime_contract)

        new_loc = c_folder + '_2'
        copydir(c_folder, new_loc)  #

        setup2 = SetUp(self.contract_path, file_name, self.new_contract_name, c_folder + '_2', self.port2, self.host, self.gas_limit)
        setup2.set_env_vars(loop, loop_number, self.agent_output2, new_loc, self.gas_limit, new_runtime_contract)
        setup2.create_config()
        new_loc = c_folder + '_3'

        copydir(c_folder, new_loc)  #

        setup3 = SetUp(self.contract_path, file_name, self.new_contract_name, c_folder + '_3', self.port3, self.host, self.gas_limit)
        setup3.set_env_vars(loop, loop_number, self.agent_output3, new_loc, self.gas_limit, new_runtime_contract)
        setup3.create_config()
        if result > 0:
            agent = Agent([setup, setup2, setup3], initial_action=result)
            info = agent.normal_loop_agent()

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
               """

            if info[0] == 1:
                run_time_threshold[loop_index] = int(info[1]["Threshold"]) * 0.99
            elif info[0] == 4:
                run_time_threshold[loop_index] = self.estimate_threshold_by_run(original_gas, first_it_gas,
                                                                           int(info[1]["gas_left"]),
                                                                           int(info[1]["last_action"]),
                                                                           added_gas_per_it)
            elif info[0] == 5:
                run_time_threshold[loop_index] = -1
            elif info[0] == 6:
                run_time_threshold[loop_index] = self.estimate_threshold_by_run(original_gas, first_it_gas,
                                                                           int(info[1]["gas_left"]),
                                                                           int(info[1]["last_action"]),
                                                                           added_gas_per_it)
            elif info[0] == 7:
                if int(info[1]["gas_left"]) > 0:
                    run_time_threshold[loop_index] = self.estimate_threshold_by_run(original_gas, first_it_gas,
                                                                               int(info[1]["gas_left"]),
                                                                               int(info[1]["last_action"]),
                                                                               added_gas_per_it)


                else:
                    run_time_threshold[loop_index] = -1
            elif info[0] >= 8:
                run_time_threshold[loop_index] = -1
            observations[loop_index] = info[0]
        else:
            run_time_threshold[loop_index] = -1
            observations[loop_index] = 8

        return run_time_threshold, observations


    def estimate_threshold_by_run(self, original_gas, initial_iteration_gas, gas_left, number_of_iterations, added_gas_per_it):
        if original_gas < 0:
            original_gas = self.gas_limit
        average_gas_per_it = int((original_gas - initial_iteration_gas - gas_left) / number_of_iterations)
        average_gas_per_it -= added_gas_per_it
        if average_gas_per_it < 0:
            average_gas_per_it = 1
        original_number_of_iteration = number_of_iterations + int(
            (number_of_iterations - 1) * added_gas_per_it / average_gas_per_it)

        return int(gas_left / average_gas_per_it) + original_number_of_iteration


    def run_nested(self, setup, contract_info, cont, file_name, loop, contract_p,
                   new_contract, f_info, new_runtime_contract, loop_index, run_time_threshold, observations,
                   estimator_threshold, o_gas, first_it_gas):
        setup.modify_contract(contract_p, new_contract)
        setup.modify_test_folder(contract_info, f_info, type='estimate')

        c_folder = self.gas_gauge_dir + "/" + file_name[:file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                              :self.new_contract_name.index('.')]

        result, original_gas, first_iteration_gas, second_iteration_gas = setup.get_results(c_folder, self.output_file_temp)
        if result >= 0:
            estimator_threshold[loop_index] = result
        else:
            """
            print("estimator was not able to estimate. used 1,000 as starting point ")
            result = 1000
            estimator_threshold[loop_index] = -2
            """
            result = -1
            estimator_threshold[loop_index] = -2

        o_gas[loop_index] = original_gas
        if original_gas < 2:
            o_gas[loop_index] = self.gas_limit
        first_it_gas[loop_index] = first_iteration_gas
        if first_iteration_gas < 2:
            first_it_gas[loop_index] = 20000

        run_time_threshold, observations = self.run_agent(file_name, loop, cont[0], new_runtime_contract, loop_index,
                                                     c_folder,
                                                     result, run_time_threshold, observations, contract_info, original_gas,
                                                     first_iteration_gas)

        return estimator_threshold, run_time_threshold, observations, o_gas, first_it_gas


    def nested_loop(self, setup, new_loop, cont, loops_info, nested_loops, contract_info, file_name, loop,
                    estimator_threshold, run_time_threshold, observations, contract_p, new_runtime_contracts,
                    loop_type, state_vars, o_gas, first_it_gas):
        cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])].replace(
            '1 == 0', 'loopCounter < 1')
        if '{' not in cont[1][int(loops_info[new_loop][1])]:
            cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])][:-1] + '{ \n'
        for n_loop in nested_loops[new_loop]:
            while nested_loops[n_loop] and estimator_threshold[n_loop] == -1:
                self.nested_loop(setup, n_loop, cont, loops_info, nested_loops, contract_info, file_name, loop,
                            estimator_threshold, run_time_threshold, observations, contract_p, new_runtime_contracts,
                            loop_type, state_vars, o_gas, first_it_gas)
            if estimator_threshold[n_loop] == -1:
                new_contract, f_info, new_runtime_contract = setup.modify_loop(cont[1], cont[2], cont[3],
                                                                               loops_info[n_loop], state_vars)
                estimator_threshold, run_time_threshold, observations, o_gas, first_it_gas = self.run_nested(setup,
                                                                                                        contract_info, cont,
                                                                                                        file_name, loop,
                                                                                                        contract_p,
                                                                                                        new_contract,
                                                                                                        f_info,
                                                                                                        new_runtime_contract,
                                                                                                        n_loop,
                                                                                                        run_time_threshold,
                                                                                                        observations,
                                                                                                        estimator_threshold,
                                                                                                        o_gas, first_it_gas)

                loop_type[n_loop] += ' Nested_Internal '
        cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])].replace(
            'loopCounter < 1', 'loopCounter <= 2')
        new_contract, f_info, new_runtime_contract = setup.modify_loop(cont[1], cont[2], cont[3], loops_info[new_loop],
                                                                       state_vars)
        estimator_threshold, run_time_threshold, observations, o_gas, first_it_gas = self.run_nested(setup, contract_info, cont,
                                                                                                file_name, loop, contract_p,
                                                                                                new_contract, f_info,
                                                                                                new_runtime_contract,
                                                                                                new_loop,
                                                                                                run_time_threshold,
                                                                                                observations,
                                                                                                estimator_threshold, o_gas,
                                                                                                first_it_gas)
        cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])].replace(
            '1 == 1', '1 == 0')

        cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])].replace(
            'loopCounter <= 2', '1 == 0')
        if '{' not in cont[1][int(loops_info[new_loop][1])]:
            cont[1][int(loops_info[new_loop][1])] = cont[1][int(loops_info[new_loop][1])][:-1] + '{ \n'
        return estimator_threshold, run_time_threshold, loop_type, new_runtime_contracts, observations, o_gas, first_it_gas


    def run_ganache(self):
        pool = ThreadPool(processes=1)
        pool.apply_async(call_cmd, [self.ganache_param + ' --port ' + str(self.port1)])
        pool2 = ThreadPool(processes=1)
        pool2.apply_async(call_cmd, [self.ganache_param + ' --port ' + str(self.port2)])
        pool3 = ThreadPool(processes=1)
        pool3.apply_async(call_cmd, [self.ganache_param + ' --port ' + str(self.port3)])


    def run(self, file_name, fuzzer, threshold, result_file, ganache_flag):
        start = timeit.default_timer()
        report = []
        contracts_info = []
        text = "Report for " + file_name + ":"
        report.append(text)
        # try:
        if not os.path.exists(self.gas_gauge_dir):

            try:
                os.mkdir(self.gas_gauge_dir)
            except OSError:
                print("Creation of the directory %s failed" % self.gas_gauge_dir)
            else:
                print("Successfully created the directory %s " % self.gas_gauge_dir)

        temp_output_path = self.gas_gauge_dir + "/" + file_name[
                                                  :file_name.index('.')] + "_testResult/" + "temp" + self.new_contract_name[
                                                                                                     :self.new_contract_name.index(
                                                                                                         ".")]

        find_loops = FindLoops(self.contract_path, file_name, self.new_contract_name, temp_output_path, self.output_file, self.solc_use)

        loops, error = find_loops.find_loops()
        if error:
            report.append("Slither was not able to scan the contract! File not supported")
            text = '-------------------------------------------------------'
            report.append(text)
            stop1 = timeit.default_timer()
            text = 'Run time = ' + str(stop1 - start) + ' seconds'
            report.append(text)
            text = '###################################################'
            report.append(text)
            text = '###################################################'
            report.append(text)
            text = '###################################################'
            report.append(text)
            output_file_write = open(result_file, "a")
            for line in report:
                # write line to output file
                output_file_write.write(str(line))
                output_file_write.write("\n")
            output_file_write.close()
            report = []

            return ganache_flag
        # setup
        if not loops:
            func_dict = {
                "File_name": file_name,
                "contract_name": "",
                "function_name": "",
                "loop_types": [],
                "first_line": [],
                "estimated_threshold": [],
                "run_time_threshold": [],
                "nested_dependency": []

            }
            contracts_info.append(func_dict)

        new_text = []
        total_loops = 0
        for loop in loops:
            total_loops += len(loop[3])
            new_text.append(
                'Function Name: ' + loop[0] + '.' + loop[1] + ', Visibility: ' + loop[2] + ', Number of Loops: ' + str(
                    len(loop[3])))
        total_funcs = len(loops)
        text = 'Found ' + str(total_loops) + ' loop'
        if total_loops > 1:
            text += 's'
        if total_loops > 0:
            text += ' in ' + str(total_funcs) + ' function'
            if total_funcs > 1:
                text += 's'
            text += ' with the following information:'
        report.append(text)
        for t in new_text:
            report.append(t)
        report.append('-------------------------------------------------------')
		
        for loop in loops:
            newcontractpath = self.gas_gauge_dir + "/" + file_name[
                                                     :file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                               :self.new_contract_name.index(
                                                                                                   '.')]
            setup = SetUp(self.contract_path, file_name, self.new_contract_name, newcontractpath, self.port1, self.host, self.gas_limit)

            contract_p = setup.run_all()
            loop_bound = find_loops.make_var_type(loop)
            state_var_in_loop, input_var_in_loop = find_loops.find_loop_bound_type(loop_bound, loop, [], [])
            new_contracts, new_nested_contracts, contract_info, loops_info = setup.get_new_contracts(loop, contract_p,
                                                                                                     state_var_in_loop)

            thr_var = ''
            if threshold:
                if input_var_in_loop:
                    thr_var = 'inputs affecting the function loop bound(s) are: '
                    for v_inp in input_var_in_loop:
                        thr_var += "input " + str(int(v_inp[1]) + 1) + " (" + str(v_inp[2]) + " " + str(v_inp[0]) + "); "
                    thr_var += '\n'
                if state_var_in_loop:
                    thr_var += 'state variables affecting the function loop bound(s) are: '
                    for v_state in state_var_in_loop:
                        thr_var += v_state[2] + " " + v_state[1] + "; "
                    thr_var += '\n'

            inp_text = ""
            if loop[2] in {'external', 'public'} and input_var_in_loop and fuzzer:
                # inputs affecting the loop bound are: input 1( MixinResolver[] calldata destinations) ;
                inp_text = 'inputs affecting the loop bound are: '
                for v_inp in input_var_in_loop:
                    inp_text += "input " + str(int(v_inp[1]) + 1) + " (" + str(v_inp[2]) + " " + str(v_inp[0]) + "); "

            if threshold or fuzzer:
                text = 'Results for ' + loop[0] + '.' + loop[1] + ': '
                report.append(text)
                if threshold and thr_var != '':
                    report.append(thr_var)
                if (not contract_info or not contract_info[0] or contract_info[1] != 'contract ') and threshold:
                    text = 'Error: Contract not supported!'
                    report.append(text)

                    text = '-------------------------------------------------------'
                    report.append(text)
                    continue
                var_flag = False
                if contract_info[3]:
                    var_flag = False
                    for input_variable in contract_info[3]:
                        if '[]' not in input_variable.translate({ord(c): None for c in
                                                                 string.whitespace}) and '[' in input_variable and ']' in input_variable:
                            size = input_variable[input_variable.index('[') + 1: input_variable.index(']')]
                            size = size.translate({ord(c): None for c in string.whitespace})
                            if not size.isdigit():
                                var_flag = True
                                break

                if var_flag:
                    text = 'Error: One or more variables is the constructor is not supported!'
                    report.append(text)
                    if fuzzer and inp_text != "":
                        report.append(inp_text)
                    text = '-------------------------------------------------------'
                    report.append(text)
                    continue

            data_type_flag = False
            for type in contract_info[3]:
                data_type_flag = True
                if 'mapping' in type:
                    break
                if type.translate({ord(c): None for c in string.whitespace}) == "":
                    data_type_flag = False
                else:
                    for t in self.datatypes:
                        if t in type:
                            data_type_flag = False
                            break
                if data_type_flag:
                    break
            if 'struct' in contract_info[3] or '][' in contract_info or data_type_flag:
                print('Cannot run contracts with struct or multi-dimensional array inputs in the constructor')
                func_dict = {
                    "File_name": file_name,
                    "contract_name": "",
                    "function_name": "",
                    "loop_types": [],
                    "first_line": [],
                    "estimated_threshold": [],
                    "run_time_threshold": [],
                    "nested_dependency": [],
                    "initial_gas": [],
                    "initial_iteration_gas": []

                }
                if threshold or fuzzer:
                    text = 'Error: Cannot run contracts with struct or multi-dimensional array inputs in the constructor'
                    report.append(text)
                    if fuzzer and inp_text != "":
                        report.append(inp_text)
                    text = '-------------------------------------------------------'
                    report.append(text)
                    continue

            setup.modify_migrations(contract_info)

            if fuzzer:

                if ganache_flag:
                    ganache_flag = False
                    self.run_ganache()

                text = 'Results of the fuzzer:'
                report.append(text)

                inps = loop[1]
                inps = inps[inps.index('(') + 1: inps.index(')')]
                inps = list(inps.split(","))

                data_type_flag = False
                for type in inps:
                    data_type_flag = True
                    if 'mapping' in type:
                        break
                    if type.translate({ord(c): None for c in string.whitespace}) == "":
                        data_type_flag = False
                    else:
                        for t in self.datatypes:
                            if t in type:
                                data_type_flag = False
                                break
                    if data_type_flag:
                        break

                if loop[2] in {'external', 'public'} and input_var_in_loop:
                    fuzz_inputs = []
                    for inp in input_var_in_loop:
                        fuzz_inputs.append(inp[1])
                    input_list = [loop[0], loop[1], fuzz_inputs]
                    fuzz_list = setup.modify_test_folder_fuzzer(input_list, contract_info[3])
                    c_folder = self.gas_gauge_dir + "/" + file_name[
                                                      :file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                                :self.new_contract_name.index(
                                                                                                    '.')]
                    t_file = self.gas_gauge_dir + "/" + file_name[
                                                    :file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                              :self.new_contract_name.index(
                                                                                                  '.')] + '/test/Test' + self.new_contract_name

                    if data_type_flag:
                        text = 'Error: Cannot run functions with struct or multi-dimensional array inputs'
                        report.append(text)
                        text = 'inputs affecting the loop bound are: '
                        for f in range(len(fuzz_list)):
                            inp_number = int(fuzz_list[f][2])
                            inp_index = inp_number
                            for var in input_var_in_loop:
                                if int(var[1]) == inp_number:
                                    inp_index = input_var_in_loop.index(var)
                                    break
                            text += 'input ' + str(int(input_var_in_loop[inp_index][1]) + 1) + ' (' + str(
                                input_var_in_loop[inp_index][2]) + ' ' + \
                                    input_var_in_loop[inp_index][0] + ')' + '; '
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue

                    test = Fuzzer(self.gas_limit, fuzz_list, c_folder, self.output_file_temp, t_file, self.fuzzer_max)
                    done = False
                    flag = False
                    if not test.action_size:
                        flag = True
                    for input_var in test.action_size:
                        if input_var <= 0:
                            flag = True
                            break
                    if flag:
                        text = 'Error: Cannot run functions with struct or multi-dimensional array inputs'
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    while not done:
                        action_space = sum(test.action_size)
                        rand_num = random.randrange(action_space)
                        # change the second input to step to change the action type
                        observation, reward, done, count, gas_left, inputs, revert = test.step(rand_num)

                    if reward == -6:
                        text = 'Does not satisfy the conditions of the fuzzer'
                        report.append(text)
                    elif reward == -10 and revert:
                        text = 'fuzzer found a revert instance after ' + str(count)
                        if count > 1:
                            text += ' tries'
                        else:
                            text += ' try'
                        report.append(text)
                        text = ''
                        for f in range(len(revert)):
                            inp_number = int(fuzz_list[f][2])
                            inp_index = inp_number
                            for var in input_var_in_loop:
                                if int(var[1]) == inp_number:
                                    inp_index = input_var_in_loop.index(var)
                                    break
                            text += 'input ' + str(int(input_var_in_loop[inp_index][1]) + 1) + '( ' + str(
                                input_var_in_loop[inp_index][2]) + ' ' + \
                                    input_var_in_loop[inp_index][0] + ') = ' + str(revert[f]) + '; '
                        report.append(text)
                    elif reward == 1:
                        text = 'fuzzer found an out of gas instance after ' + str(count)
                        if count > 1:
                            text += ' tries'
                        else:
                            text += ' try'
                        report.append(text)
                        text = ''
                        for f in range(len(inputs)):
                            inp_number = int(fuzz_list[f][2])
                            inp_index = inp_number
                            for var in input_var_in_loop:
                                if int(var[1]) == inp_number:
                                    inp_index = input_var_in_loop.index(var)
                                    break
                            text += 'input ' + str(int(input_var_in_loop[inp_index][1]) + 1) + '( ' + str(
                                input_var_in_loop[inp_index][2]) + ' ' + \
                                    input_var_in_loop[inp_index][0] + ') = ' + str(inputs[f]) + '; '
                        report.append(text)
                    else:

                        if reward == -2:
                            text = 'There is a required statement or requirement in the contract that cannot be handled by the fuzzer'
                            report.append(text)
                        elif reward in [-1, -3]:
                            text = 'There is an error that cannot be handled by the fuzzer'
                            report.append(text)
                        elif reward == -4:
                            text = 'Abstract contracts with constructors are not supported'
                            report.append(text)
                        elif reward == -5:
                            text = 'one of the input types to the function or constructor is not supported'
                            report.append(text)
                        else:
                            text = 'fuzzer did not find a set after ' + str(count) + ' tries'
                            report.append(text)
                        text = 'inputs affecting the loop bound are: '
                        for f in range(len(inputs)):
                            inp_number = int(fuzz_list[f][2])
                            inp_index = inp_number
                            for var in input_var_in_loop:
                                if int(var[1]) == inp_number:
                                    inp_index = input_var_in_loop.index(var)
                                    break
                            text += 'input ' + str(int(input_var_in_loop[inp_index][1]) + 1) + '( ' + str(
                                input_var_in_loop[inp_index][2]) + ' ' + \
                                    input_var_in_loop[inp_index][0] + ') ' + '; '
                        report.append(text)
                else:
                    text = 'Does not satisfy the conditions of the fuzzer'
                    report.append(text)
                text = '-------------------------------------------------------'
                report.append(text)

            if threshold:
                text = 'Results of the Threshold Finder:'
                report.append(text)

                if ganache_flag:
                    ganache_flag = False
                    self.run_ganache()
                estimator_threshold = []
                run_time_threshold = []
                loop_type = []
                first_line = []
                o_gas = []
                first_it_gas = []
                observations = []
                uncommented_contract = setup.format_contract(contract_p)
                support_flag = False

                for l in loops_info:
                    estimator_threshold.append(-1)
                    run_time_threshold.append(-1)
                    loop_type.append("")
                    if not uncommented_contract or not l or len(l) < 1 or len(uncommented_contract) < l[1]:
                        support_flag = True
                        break
                    first_line.append(uncommented_contract[l[1]])
                    o_gas.append(1)
                    first_it_gas.append(0)
                    observations.append(-1)

                if support_flag:
                    report.append('Error: Contract or Function not supported.')
                    text = '-------------------------------------------------------'
                    report.append(text)
                    continue

                data_type_flag = False
                cont_index = -1
                if not new_contracts and not new_nested_contracts:
                    report.append('Error: Contract or Function not supported.')
                    text = '-------------------------------------------------------'
                    report.append(text)
                    continue
                for cont in new_contracts:
                    cont_index += 1
                    data_type_flag = False
                    for type in cont[0][1][1]:
                        data_type_flag = True
                        if 'mapping' in type:
                            break
                        if type.translate({ord(c): None for c in string.whitespace}) == "":
                            data_type_flag = False
                        else:
                            for t in self.datatypes:
                                if t in type:
                                    data_type_flag = False
                                    break
                        if data_type_flag:
                            break

                    if 'struct' in cont[0][1][1] or '][' in cont[0][1][1] or data_type_flag:
                        print('Error: Cannot run functions with struct or multi-dimensional array inputs')
                        func_dict = {
                            "File_name": file_name,
                            "contract_name": "",
                            "function_name": "",
                            "loop_types": [],
                            "first_line": [],
                            "estimated_threshold": [],
                            "run_time_threshold": [],
                            "nested_dependency": [],
                            "initial_gas": [],
                            "initial_iteration_gas": [],
                            "observation": ""

                        }
                        text = 'Error: Cannot run functions with struct or multi-dimensional array inputs'
                        report.append(text)
                        continue
                    if '].length' in ' '.join([str(elem) for elem in loop[3]]):
                        text = 'Error: Cannot run loops with struct or multi-dimensional array in their conditions'
                        print(text)
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue

                    print("loop number:" + str(cont[1]))
                    setup.modify_contract(contract_p, cont[0][0])
                    setup.modify_test_folder(contract_info, cont[0][1], type='estimate')

                    c_folder = self.gas_gauge_dir + "/" + file_name[
                                                      :file_name.index('.')] + "_testResult/" + self.new_contract_name[
                                                                                                :self.new_contract_name.index(
                                                                                                    '.')]

                    result, original_gas, first_iteration_gas, second_iteration_gas = setup.get_results(c_folder,
                                                                                                        self.output_file_temp)
                    if result >= 0:
                        estimator_threshold[cont[1]] = result
                    elif result == -10:
                        text = 'The threshold  is 1; the gas is not sufficient even for 1 iteration!'
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    elif result == -40:
                        report.append('Error: Loop is not reachable.')
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    elif result == -30:
                        report.append('Error: Contract or Function not supported.')
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    elif result == -50:
                        report.append(
                            'Error: Contract with internal constructor cannot be created directly. Refer to the original contract with the loop.')
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    elif result == -60:
                        report.append('Error: One or more variables is the constructor is not supported!')
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    elif result == -20:
                        text = 'Error: There is an error that cannot be handled'
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    else:
                        report.append('Error: The first instance reverted')
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue

                        # print("estimator was not able to estimate. used 1,000 as starting point ")
                        # result = 1000
                        # estimator_threshold[cont[1]] = -2
                    loop_type[cont[1]] = 'Normal'
                    o_gas[cont[1]] = original_gas
                    first_it_gas[cont[1]] = first_iteration_gas

                    run_time_threshold, observations = self.run_agent(file_name, loop, cont[1], cont[0][2], cont[1],
                                                                 c_folder,
                                                                 result, run_time_threshold, observations,
                                                                 contract_info, original_gas,
                                                                 first_iteration_gas, )

                nested_loops = setup.find_nested_loop_order(loops_info)
                contract_p = setup.run_all()
                data_type_flag = False
                for cont in new_nested_contracts:
                    data_type_flag = False
                    for type in list(cont[3][2].split(",")):
                        data_type_flag = True
                        if 'mapping' in type:
                            break
                        if type.translate({ord(c): None for c in string.whitespace}) == "":
                            data_type_flag = False
                        else:
                            for t in self.datatypes:
                                if t in type:
                                    data_type_flag = False
                                    break
                        if data_type_flag:
                            break
                    if 'struct' in cont[3][2] or '][' in cont[3][2] or data_type_flag:
                        print('Error: Cannot run functions with struct or multi-dimensional array inputs')
                        func_dict = {
                            "File_name": file_name,
                            "contract_name": "",
                            "function_name": "",
                            "loop_types": [],
                            "first_line": [],
                            "estimated_threshold": [],
                            "run_time_threshold": [],
                            "nested_dependency": [],
                            "initial_gas": [],
                            "initial_iteration_gas": [],
                            "observation": ""

                        }
                        text = 'Error: Cannot run functions with struct or multi-dimensional array inputs'
                        report.append(text)
                        continue
                    loop_type[cont[0]] += ' Nested_External '
                    print("loop number:" + str(cont[0]))
                    estimator_threshold, run_time_threshold, loop_type, new_contracts, observations, o_gas, first_it_gas = self.nested_loop(
                        setup, cont[0],
                        cont,
                        loops_info,
                        nested_loops,
                        contract_info,
                        file_name, loop,
                        estimator_threshold,
                        run_time_threshold,
                        observations,
                        contract_p, [],
                        loop_type,
                        state_var_in_loop, o_gas, first_it_gas)
                func_dict = {
                    "File_name": file_name,
                    "contract_name": loop[0],
                    "function_name": loop[1],
                    "loop_types": loop_type,
                    "first_line": first_line,
                    "estimated_threshold": estimator_threshold,
                    "run_time_threshold": run_time_threshold,
                    "nested_dependency": nested_loops,
                    "initial_gas": o_gas,
                    "initial_iteration_gas": first_it_gas,
                    "observation": observations

                }
                contracts_info.append(func_dict)

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
                       """
                for i in range(len(func_dict['loop_types'])):
                    if func_dict['loop_types'][i] == '':
                        continue
                    text = 'for loop ' + str(i + 1) + ' in ' + func_dict['contract_name'] + '.' + func_dict[
                        'function_name'] + ':'
                    report.append(text)
                    text = 'The type is ' + func_dict['loop_types'][i]
                    if func_dict['loop_types'][i].translate({ord(c): None for c in string.whitespace}) == "":
                        if func_dict['nested_dependency'][i]:
                            text += 'Nested_External '
                        for d in func_dict['nested_dependency']:
                            for de in d:
                                if int(de) == i:
                                    text += 'Nested_Internal '
                                    break
                    report.append(text)

                    obser = func_dict['observation'][i]
                    if obser == 4:
                        text = 'The threshold is over max, the result is estimated'
                        report.append(text)
                    if obser == 5:
                        text = 'gas usage does not change by the change of the loop bound'
                        report.append(text)
                    if obser == 6:
                        text = 'Reached max tries! The result is estimated'
                        report.append(text)
                    if obser == 7:
                        text = 'Was not able to find the Threshold! The result is estimated'
                        report.append(text)
                    if obser == 8:
                        text = 'Error: Function or Contract not supported'
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    if obser == 9:
                        text = 'There is a required statement or requirement in the contract that cannot be handled by the Finder'
                        report.append(text)
                        text = '-------------------------------------------------------'
                        report.append(text)
                        continue
                    thr = func_dict['run_time_threshold'][i]
                    if func_dict['run_time_threshold'][i] < 3:
                        text = 'Was not able to find the Threshold! The result is estimated \n'
                        text += 'For gas limit = ' + str(self.gas_limit) + ', the calculated threshold = ' + str(round(
                            func_dict['estimated_threshold'][i]))
                    else:
                        text = 'For gas limit = ' + str(self.gas_limit) + ', the calculated threshold = ' + str(round(
                            func_dict['run_time_threshold'][i]))
                    if func_dict['nested_dependency'][i]:
                        text += ' considering inner loops are not executed'
                    report.append(text)
                    tr = func_dict['run_time_threshold'][i]
                    average_gas = 0
                    if tr < 3:
                        average_gas = (func_dict["initial_gas"][i] - func_dict['initial_iteration_gas'][i]) / \
                                      func_dict['estimated_threshold'][i]
                    else:
                        average_gas = (func_dict["initial_gas"][i] - func_dict['initial_iteration_gas'][i]) / \
                                      func_dict['run_time_threshold'][i]

                    text = 'gas consumption for the first iteration = ' + str(round(
                        func_dict['initial_iteration_gas'][i])) + '; '
                    text += 'average gas consumption for other iterations = ' + str(round(average_gas))
                    report.append(text)

                    text = 'Threshold formula (gasleft() is the global function gasleft() placed before entering the ' \
                           'loop '
                    if func_dict['nested_dependency'][i]:
                        text += ', loop_i_usage is the gas consumption of loop i'
                    text += ') ='
                    report.append(text)

                    text = '(gasleft() - ' + str(round(func_dict['initial_iteration_gas'][i])) + ') / (' + str(round(average_gas))
                    for nested_l in func_dict['nested_dependency'][i]:
                        text += ' + loop_' + str(int(nested_l) + 1) + '_usage'

                    text += ')'
                    report.append(text)

                    text = '-------------------------------------------------------'
                    report.append(text)

        stop1 = timeit.default_timer()
        text = 'Run time = ' + str(stop1 - start) + ' seconds'
        report.append(text)
        text = '###################################################'
        report.append(text)
        text = '###################################################'
        report.append(text)
        text = '###################################################'
        report.append(text)
        print(contracts_info)
        output_file_write = open(result_file, "a")
        for line in report:
            # write line to output file
            output_file_write.write(str(line))
            output_file_write.write("\n")
        output_file_write.close()
        report = []

        """
        except:
            text = 'Error in ' + str(file_name)
            report.append(text)
            text = '*******************************************************'
            report.append(text)
            report.append(text)
            text = '###################################################'
            report.append(text)
            text = '###################################################'
            report.append(text)
            text = '###################################################'
            report.append(text)
            output_file_write = open(result_file, "a")
            for line in report:
                # write line to output file
                output_file_write.write(str(line))
                output_file_write.write("\n")
            output_file_write.close()
            report = []
        
        """

        return ganache_flag


    def run_tool(self, fuzzer_flag, threshold_flag, output_file):
        ganache_flag = True
        if self.contract_file != '':
            self.run(self.contract_file, fuzzer_flag, threshold_flag, output_file, ganache_flag)
        else:
            for file in glob.glob(os.path.join(self.contract_path, '*.sol')):
                file_name = file[file.index(self.contract_path) + len(self.contract_path):]
                ganache_flag = self.run(file_name, fuzzer_flag, threshold_flag, output_file, ganache_flag)

