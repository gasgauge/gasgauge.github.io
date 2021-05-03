import os
import shutil
import string


class SetUp:
    def __init__(self, contract_path, original_name, file_name, folder_name, port, ip, gas_limit):
        self.contract_path = contract_path
        self.original_name = original_name
        self.file_name = file_name
        self.folder_name = folder_name
        self.port = port
        self.ip = ip
        self.env_input_list = []
        self.env_contract_path = ''
        self.env_loop_number = 0
        self.env_output = ''
        self.env_contract_folder = ''
        self.env_gas_limit = gas_limit

    def format_contract(self, contract_path):

        file = open(contract_path, "r")
        lines = file.readlines()
        new_contract = []
        c_flag1 = False
        c_flag2 = False
        counter = 0

        for line in lines:
            new_line = line
            while '/*' in line and '*/' in line:
                temp = line[:line.index('*/') + len('*/')]
                temp = temp[temp.rfind('/*'):]
                new_line = line.replace(temp, '')
                line = new_line
            if '//' in line and (line[:line.index('//')].count('"') % 2 == 0):
                new_line = line[:line.index('//')] + '\n'
            elif '/**' in line:
                c_flag1 = True
            elif '/*' in line:
                c_flag2 = True
            if c_flag1:
                new_line = '\n'
                if ('/*' in line and '/**' not in line) or '*/' in line:
                    c_flag1 = False
            if c_flag2:
                new_line = '\n'
                if '*/' in line:
                    c_flag2 = False

            new_contract.append(new_line)

        counter = 0
        for line in new_contract:
            if ' payable[] ' in line:
                new_contract[counter] = new_contract[counter].replace(' payable[] ', ' [] ')
            c_line = line.translate({ord(c): None for c in string.whitespace})
            if ' pure ' in line:
                new_contract[counter] = new_contract[counter].replace(' pure ', ' ')
            elif c_line == 'pure':
                new_contract[counter] = ' '
            elif ' pure\n' in line:
                new_contract[counter] = new_contract[counter].replace(' pure\n', ' \n')
            elif 'pure ' in line and line.index('pure ') == 0:
                new_contract[counter] = new_contract[counter].replace('pure ', '')
            if ' view ' in line:
                new_contract[counter] = new_contract[counter].replace(' view ', ' ')
            elif c_line == 'view':
                new_contract[counter] = ' '
            elif ' view\n' in line:
                new_contract[counter] = new_contract[counter].replace(' view\n', ' \n')
            elif 'view ' in line and line.index('view ') == 0:
                new_contract[counter] = new_contract[counter].replace('view ', '')
            if 'require(' in line and c_line.index('require') == 0:
                i = 0
                while ';' not in new_contract[counter + i]:
                    if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                        char = '_ ;'
                        if char not in new_contract[counter + i]:
                            char = '_;'
                        if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                            new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                                :new_contract[counter + i].index(char)] + ' */ ' + \
                                                        new_contract[counter + i][
                                                        new_contract[counter + i].index(char):]
                    else:
                        new_contract[counter + i] = '// ' + new_contract[counter + i]
                    i += 1
                if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                    char = '_ ;'
                    if char not in new_contract[counter + i]:
                        char = '_;'
                    if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                        new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                            :new_contract[counter + i].index(char)] + ' */ ' + \
                                                    new_contract[counter + i][
                                                    new_contract[counter + i].index(char):]
                else:
                    new_contract[counter + i] = '// ' + new_contract[counter + i]
                i = - 1
                while ';' not in new_contract[counter + i] and '{' not in new_contract[counter + i] and '}' not in \
                        new_contract[counter + i]:
                    if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                        char = '_ ;'
                        if char not in new_contract[counter + i]:
                            char = '_;'
                        if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                            new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                                :new_contract[counter + i].index(char)] + ' */ ' + \
                                                        new_contract[counter + i][
                                                        new_contract[counter + i].index(char):]
                    else:
                        new_contract[counter + i] = '// ' + new_contract[counter + i]
                    i -= 1
            if (' revert(' in line or 'revert (' in line) and 'case' not in line:
                i = - 1
                if '{' not in line or ('{' in line and line.index('{') > line.index('revert')):
                    while ';' not in new_contract[counter + i] and '{' not in new_contract[counter + i] and '}' not in \
                            new_contract[counter + i]:
                        if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                            char = '_ ;'
                            if char not in new_contract[counter + i]:
                                char = '_;'
                            if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                                new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                                    :new_contract[counter + i].index(char)] + ' */ ' + \
                                                            new_contract[counter + i][
                                                            new_contract[counter + i].index(char):]
                        else:
                            new_contract[counter + i] = '// ' + new_contract[counter + i]
                        i -= 1
                i = 0
                while ';' not in new_contract[counter + i] and '}' not in new_contract[counter + i]:
                    if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                        char = '_ ;'
                        if char not in new_contract[counter + i]:
                            char = '_;'
                        if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                            new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                                :new_contract[counter + i].index(char)] + ' */ ' + \
                                                        new_contract[counter + i][
                                                        new_contract[counter + i].index(char):]
                    else:
                        new_contract[counter + i] = '// ' + new_contract[counter + i]
                    i += 1
                if ';' in new_contract[counter + i] and '}' not in new_contract[counter + i]:
                    if '_;' in new_contract[counter + i] or '_ ;' in new_contract[counter + i]:
                        char = '_ ;'
                        if char not in new_contract[counter + i]:
                            char = '_;'
                        if new_contract[counter + i].index(char) > new_contract[counter + i].index(';'):
                            new_contract[counter + i] = '/* ' + new_contract[counter + i][
                                                                :new_contract[counter + i].index(char)] + ' */ ' + \
                                                        new_contract[counter + i][
                                                        new_contract[counter + i].index(char):]
                    else:
                        new_contract[counter + i] = '// ' + new_contract[counter + i]
                if '}' in line and line.index('}') < line.index('revert'):
                    new_contract[counter] = line[: line.index('}') + 1] + '// ' + line[line.index('}') + 1:]
                else:
                    if '_;' in new_contract[counter] or '_ ;' in new_contract[counter]:
                        char = '_ ;'
                        if char not in new_contract[counter]:
                            char = '_;'
                        if new_contract[counter].index(char) > new_contract[counter].index(';'):
                            new_contract[counter] = '/* ' + new_contract[counter][
                                                                :new_contract[counter].index(char)] + ' */ ' + \
                                                        new_contract[counter][
                                                        new_contract[counter].index(char):]
                    else:
                        new_contract[counter] = '// ' + new_contract[counter]

                i = 1
                """
                while ';' not in new_contract[counter - i] and '{' not in new_contract[counter - i]:
                    i += 1
                i -= 1
                i *= -1
                new_contract[counter + i] = '// ' + new_contract[counter + i]
                while ';' not in new_contract[counter + i] and '}' not in new_contract[counter + i]:
                    new_contract[counter + i] = '// ' + new_contract[counter + i]
                    i += 1
                """

            counter += 1

        return new_contract

    def set_env_vars(self, env_inputs, env_loop_number, env_output, env_contract_folder, env_gas_limit,
                     run_time_contract):
        self.env_input_list = env_inputs
        self.env_contract_path = env_contract_folder + '/contracts/' + self.file_name
        self.env_loop_number = env_loop_number
        self.env_output = env_output
        self.env_contract_folder = env_contract_folder
        self.env_gas_limit = env_gas_limit
        self.contract, self.c_info, self.f_info, self.loops_info, self.normal_loop, self.nested_loops = self.find_loop_info(
            self.env_input_list,
            self.env_contract_path)
        constructor = self.find_constructor(self.env_input_list[0], self.env_contract_path)
        self.c_info.append(constructor)
        self.run_time_contract = run_time_contract

    def create_config(self):
        text_list = ["module.exports = {", "\t networks: {", "\t \t development: {",
                     "\t \t \t host: \"" + self.ip + "\" ,",
                     "\t \t \t port: " + str(self.port) + " ,", "\t \t \t  network_id: \"*\",",
                     "\t \t \t  gas: " + str(self.env_gas_limit), "\t \t },",
                     "\t \t test: {",
                     "\t \t \t host: \"" + self.ip + "\" ,", "\t \t \t port: " + str(self.port) + " ,",
                     "\t \t \t network_id: \"*\",",
                     "\t \t \t  gas: " + str(self.env_gas_limit), "\t \t },", "\t },", "};"]

        # print("self.folder_name + /truffle-config.js", self.folder_name + "/truffle-config.js")

        output_file = open(self.folder_name + "/truffle-config.js", "w")
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

    def create_contract_folder(self):
        contract_file = self.contract_path + self.original_name
        contract_folder = self.folder_name + "/contracts"
        try:
            os.mkdir(contract_folder)
        except OSError:
            print("Creation of the directory %s failed" % contract_folder)
        else:
            print("Successfully created the directory %s " % contract_folder)

        text_list = ["pragma solidity >=0.4.25 <0.7.0;", "", "contract Migrations {", "\t address public owner;",
                     "\t uint public last_completed_migration;", "", "\t modifier restricted() {",
                     "\t \t if (msg.sender == owner) _;", "\t }", "", "\t constructor() public {",
                     "\t \t owner = msg.sender;", "\t }", "",
                     "\t function setCompleted(uint completed) public restricted {",
                     "\t \t last_completed_migration = completed;", "\t }", "}"]
        output_file = open(contract_folder + '/' + "Migrations.sol", "w")
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

        shutil.copy(contract_file, contract_folder + '/' + self.file_name, follow_symlinks=True)
        return contract_folder + '/' + self.file_name

    def modify_loop(self, contract, c_info, f_info, l_info, state_vars, it_counter=2):

        new_contract_estimator = list(contract)
        new_line_counter = 1
        line = new_contract_estimator[int(c_info[2])]
        c_line = line.translate({ord(c): None for c in string.whitespace})
        flag = False
        s_line = 0
        modified_state = []

        # if the line includes anything after '{' then split the line into 2
        if c_line[c_line.index('{') + 1:] != '':
            new_contract_estimator[int(c_info[2])] = line[:line.index('{') + 1] + '\n'
            new_contract_estimator.insert(int(c_info[2]) + new_line_counter, line[line.index('{') + 1:])
            flag = True

        # Add the required variables
        new_line = ' '
        new_contract_estimator.insert(int(c_info[2]) + new_line_counter, new_line + ' \n')
        new_c_line = int(c_info[2]) + new_line_counter
        if flag:
            new_line_counter += 1
        new_contract_run_time = new_contract_estimator.copy()
        new_line_counter_run = new_line_counter
        new_line = '    uint[] returnValues' + f_info[0] + ';'
        new_contract_estimator.insert(new_c_line, new_line + ' \n')
        new_line_counter += 1
        new_line = '    uint initialGasForLoopIn' + f_info[0] + ' = 0;'
        new_contract_estimator.insert(new_c_line, new_line + ' \n')
        new_line_counter += 1
        new_line = '    uint initialItForLoopIn' + f_info[0] + ' = 0;'
        new_contract_estimator.insert(new_c_line, new_line + ' \n')
        new_line_counter += 1
        new_line = '    uint gasForLoopIn' + f_info[0] + ' = 0;'
        new_contract_estimator.insert(new_c_line, new_line + ' \n')
        new_line_counter += 1

        # find_loops the inputs to the original function and use them for the new function
        # f_info = [func_name, function_vis, func_inputs, function_line]
        inputs = list(f_info[2].split(","))
        function_name = 'getStateVarIn' + f_info[0]
        function_info = [function_name, inputs]
        new_line = 'function ' + function_name + '('
        counter = 1
        if inputs != ['']:
            for var_type in inputs:
                t = ' '
                if '[' in var_type and ' memory' not in var_type:
                    t = ' memory '
                if 'string' in var_type and 'memory' not in var_type and 'memory' not in t:
                    var_type += ' memory '
                new_line += var_type + t + 'input' + str(counter)
                if counter < len(inputs):
                    new_line += ', '
                counter += 1
        # add the new function signature
        new_line += ') public returns '
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '    ' + new_line + '(uint[] memory) {\n')
        new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run, '    ' + new_line + '(uint) {\n')
        new_line_counter += 1
        new_line_counter_run += 1

        if f_info[0] != 'constructor':

            ###############
            for state in state_vars:
                inp = state[2]
                if 'mapping(' in inp:
                    continue
                input_name = state[1]
                state_string = "\t\t" + input_name + " = "
                if ']' in inp:
                    inp = inp[:inp.index(']') + 1]
                if "[]" in inp:
                    if '.' in inp:
                        array_type = inp[inp.index('.') + 1: inp.index('[')]
                        state_string = "\t\t" + array_type + ' memory threshold_new_var_' + input_name + '; '
                        for i in range(it_counter + 1):
                            state_string += input_name + '.push(threshold_new_var_' + input_name + '); '
                    else:
                        state_string += "new " + inp + "(" + str(it_counter + 1) + ");"
                elif "[" and "]" in inp:
                    continue
                elif "int" in inp:
                    state_string += str(3) + ';'
                elif "address" in inp:
                    state_string += "0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2;"
                elif "byte" in inp:
                    state_string += "0x00;"
                elif "string" in inp:
                    state_string += "\" \";"
                elif "bool" in inp:
                    state_string += "true;"
                new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + state_string + '\n')
                new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run, '        ' + state_string + '\n')
                modified_state.append([state_string, int(f_info[3]) + new_line_counter_run])
                s_line = new_line_counter + 2
                new_line_counter += 1
                new_line_counter_run += 1

            ##############

            # call the original function
            new_line = '        ' + f_info[0] + '('
            counter = 1
            if inputs != ['']:
                for var_type in inputs:
                    new_line += 'input' + str(counter)
                    if counter < len(inputs):
                        new_line += ', '
                    counter += 1
            new_line += ');'
            new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + new_line + '\n')
            new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run, '        ' + new_line + '\n')
            new_line_counter += 1
            new_line_counter_run += 1

        # return the state variable

        new_line = 'returnValues' + f_info[0] + '.push(initialGasForLoopIn' + f_info[0] + ');'
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + new_line + '\n')
        new_line_counter += 1
        new_line = 'returnValues' + f_info[0] + '.push(initialItForLoopIn' + f_info[0] + ');'
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + new_line + '\n')
        new_line_counter += 1
        new_line = 'returnValues' + f_info[0] + '.push(gasForLoopIn' + f_info[0] + ');'
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + new_line + '\n')
        new_line_counter += 1
        new_line = '        return returnValues' + f_info[0] + ';'
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '        ' + new_line + '\n')
        new_line_counter += 1
        new_contract_estimator.insert(int(f_info[3]) + new_line_counter, '    } \n')
        new_line_counter += 1
        new_line = '        return gasleft();'
        new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run, '        ' + new_line + '\n')
        new_line_counter_run += 1
        new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run, '    } \n')
        new_line_counter_run += 1

        i = 0
        while '{' not in new_contract_run_time[int(f_info[3]) + new_line_counter_run + i].translate(
                {ord(c): None for c in string.whitespace}):
            i += 1
        if new_contract_run_time[int(f_info[3]) + new_line_counter_run + i].translate(
                {ord(c): None for c in string.whitespace})[-1] != '{':
            new_contract_run_time[int(f_info[3]) + new_line_counter_run + i] = new_contract_run_time[int(
                f_info[3]) + new_line_counter_run + i][: new_contract_run_time[
                                                             int(f_info[3]) + new_line_counter_run + i].index(
                '{') + 1] + '\n'
            new_line = new_contract_run_time[int(
                f_info[3]) + new_line_counter_run + i][new_contract_run_time[
                                                           int(f_info[3]) + new_line_counter_run + i].index(
                '{') + 1:] + '\n'
            new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run + i + 1, new_line + ' \n')
            new_line_counter_run += 1
            i += 1

        new_line = '    uint loopCounter = 0;'
        if new_line + ' \n' not in new_contract_run_time:
            new_contract_run_time.insert(int(f_info[3]) + new_line_counter_run + i + 1, new_line + ' \n')
            new_line_counter_run += 1

        i = 0
        while '{' not in new_contract_estimator[int(f_info[3]) + new_line_counter + i].translate(
                {ord(c): None for c in string.whitespace}):
            i += 1
        if new_contract_estimator[int(f_info[3]) + new_line_counter + i].translate(
                {ord(c): None for c in string.whitespace})[-1] != '{':
            new_contract_estimator[int(f_info[3]) + new_line_counter + i] = new_contract_estimator[int(
                f_info[3]) + new_line_counter + i][: new_contract_estimator[
                                                         int(f_info[3]) + new_line_counter + i].index(
                '{') + 1] + '\n'
            new_line = new_contract_estimator[int(
                f_info[3]) + new_line_counter + i][new_contract_estimator[
                                                       int(f_info[3]) + new_line_counter + i].index(
                '{') + 1:] + '\n'
            new_contract_estimator.insert(int(f_info[3]) + new_line_counter + i + 1, new_line + ' \n')
            new_line_counter += 1
            i += 1

        new_line = '    uint loopCounter = 0;'
        if new_line + ' \n' not in new_contract_estimator:
            new_contract_estimator.insert(int(f_info[3]) + new_line_counter + i + 1, new_line + ' \n')
            new_line_counter += 1

        if l_info[0] in {'for', 'while'}:
            new_contract_run_time[int(l_info[1]) + new_line_counter_run] = new_contract_run_time[
                int(l_info[1]) + new_line_counter_run].replace(
                '1 == 0', 'loopCounter <= ' + str(it_counter))
        new_line = '                	loopCounter = loopCounter + 1;'
        if l_info[0] == 'dowhile':
            new_contract_run_time.insert(int(l_info[2]) + new_line_counter_run - 1, new_line + '\n')
            new_contract_run_time[int(l_info[2]) + new_line_counter_run] = new_contract_run_time[
                int(l_info[2]) + new_line_counter_run].replace(
                '1 == 0', 'loopCounter <= ' + str(it_counter))
        else:
            new_contract_run_time.insert(int(l_info[2]) + new_line_counter_run, new_line + '\n')

        i = 0
        while new_contract_run_time[int(l_info[1]) + new_line_counter_run + i].translate(
                {ord(c): None for c in string.whitespace}) == '':
            i -= 1
        if '{' not in new_contract_run_time[int(l_info[1]) + new_line_counter_run + i] or '//' in new_contract_run_time[
            int(l_info[1]) + new_line_counter_run + i]:
            new_contract_run_time[int(l_info[1]) + new_line_counter_run + i] = new_contract_run_time[
                                                                                   int(l_info[
                                                                                           1]) + new_line_counter_run + i][
                                                                               :-1] + '{' + '\n'

        # Add required variables to estimate the max iterations
        # loop_char, start_of_loop, end_of_loop
        i = 0
        while new_contract_estimator[int(l_info[1]) + new_line_counter + i].translate(
                {ord(c): None for c in string.whitespace}) == '':
            i -= 1
        if '{' not in new_contract_estimator[int(l_info[1]) + new_line_counter + i] or '//' in new_contract_estimator[
            int(l_info[1]) + new_line_counter + i]:
            new_contract_estimator[int(l_info[1]) + new_line_counter + i] = new_contract_estimator[
                                                                                int(l_info[1]) + new_line_counter + i][
                                                                            :-1] + '{' + '\n'

        if l_info[0] == 'dowhile':
            new_c_line = int(l_info[2]) + new_line_counter_run
        else:
            new_c_line = int(l_info[1]) + new_line_counter_run

        new_line = '        initialGasForLoopIn' + f_info[0] + '  = gasleft();'
        new_contract_estimator.insert(int(l_info[1]) + new_line_counter, new_line + ' \n')
        new_line_counter += 1

        new_line = '        initialItForLoopIn' + f_info[0] + '  = gasleft();'
        new_contract_estimator.insert(int(l_info[1]) + new_line_counter, new_line + '\n')
        new_line_counter += 1
        if l_info[0] in {'for', 'while'}:
            new_contract_estimator[int(l_info[1]) + new_line_counter] = new_contract_estimator[
                int(l_info[1]) + new_line_counter].replace(
                '1 == 0', 'loopCounter <= ' + str(it_counter))
            new_line_counter += 1

        new_line = '                gasForLoopIn' + f_info[0] + ' = gasleft();'
        new_contract_estimator.insert(int(l_info[1]) + new_line_counter, new_line + '\n')

        # Adding conditions inside the loop
        new_line = '                gasForLoopIn' + f_info[0] + ' = gasForLoopIn' + f_info[0] + ' - gasleft();'
        new_contract_estimator.insert(int(l_info[2]) + new_line_counter, new_line + '\n')
        new_line_counter += 1

        new_line = '                if(loopCounter == 0){'
        new_contract_estimator.insert(int(l_info[2]) + new_line_counter, new_line + '\n')
        new_line_counter += 1

        new_line = '                	initialItForLoopIn' + f_info[0] + ' =  initialItForLoopIn' + f_info[
            0] + '- gasleft(); '
        new_contract_estimator.insert(int(l_info[2]) + new_line_counter, new_line + '\n')
        new_line_counter += 1
        new_line = '            }'
        new_contract_estimator.insert(int(l_info[2]) + new_line_counter, new_line + '\n')
        new_line_counter += 1

        new_line = '                	loopCounter = loopCounter + 1;'
        new_contract_estimator.insert(int(l_info[2]) + new_line_counter, new_line + '\n')
        new_line_counter += 1

        return new_contract_estimator, function_info, [new_contract_run_time, new_c_line, s_line, modified_state]

    def find_constructor(self, cont_name, contract_path):
        uncommented_contract = self.format_contract(contract_path)
        lines = list(uncommented_contract)
        line_counter = -1
        contract_name = ""
        for line in lines:
            c_line = line.translate({ord(c): None for c in string.whitespace})
            line_counter += 1
            if ("contract " in line and c_line.index('contract') == 0) or (
                    "library " in line and c_line.index('library') == 0) or (
                    "interface " in line and c_line.index('interface') == 0):
                if "require(" in line:
                    continue
                cont = "contract "
                if "interface " in line and c_line.index('interface') == 0:
                    cont = "interface "
                elif "library " in line and c_line.index('library') == 0:
                    cont = "library "
                temp_line = line[line.index(cont) + len(cont):]
                if " is" in temp_line:
                    contract_name = temp_line[: temp_line.index(" is")].translate(
                        {ord(c): None for c in string.whitespace})
                else:
                    char = '\n'
                    if '{' in temp_line:
                        char = '{'
                    contract_name = temp_line[:temp_line.index(char)].translate(
                        {ord(c): None for c in string.whitespace})

            # find_loops the constructor in the contract
            if "constructor" in line and c_line.index(
                    "constructor") == 0 and contract_name == cont_name:
                temp = line
                t_counter = 1
                while ')' not in temp:
                    temp += lines[line_counter + t_counter]
                    t_counter += 1
                temp = temp.replace('\n', ' ')
                temp = temp.replace('\t', ' ')
                inputs = temp[temp.index('(') + 1:temp.index(')')]
                if inputs.translate({ord(c): None for c in string.whitespace}) != '':
                    input_list = list(inputs.split(','))
                    for i in range(len(input_list)):
                        while input_list[i][-1] == ' ':
                            input_list[i] = input_list[i][:-1]
                        while input_list[i][0] == ' ':
                            input_list[i] = input_list[i][1:]
                        input_list[i] = input_list[i][:input_list[i].rfind(" ")]
                    return input_list
                else:
                    return []
        return []

    def find_loop_info(self, input_list, contract_path):
        cont_name = input_list[0]
        function_vis = input_list[2]
        func_name = input_list[1][:input_list[1].index('(')]
        func_inputs = input_list[1][input_list[1].index('(') + 1: input_list[1].index(')')]
        uncommented_contract = self.format_contract(contract_path)
        lines = list(uncommented_contract)

        contract_name = ""
        function_flag = False
        line_counter = -1
        contract_info = []
        function_info = []
        loops_info = []

        for line in uncommented_contract:
            c_line = line.translate({ord(c): None for c in string.whitespace})
            line_counter += 1

            # find_loops the matching contract
            if ("contract " in line and c_line.index('contract') < 2) or (
                    "library " in line and c_line.index('library') < 2) or (
                    "interface " in line and c_line.index('interface') < 2):
                if "require(" in line:
                    continue
                cont = "contract "
                if "interface " in line and c_line.index('interface') < 2:
                    cont = "interface "
                elif "library " in line and c_line.index('library') < 2:
                    cont = "library "
                temp_line = line[line.index(cont) + len(cont):]
                if " is" in temp_line:
                    contract_name = temp_line[: temp_line.index(" is")].translate(
                        {ord(c): None for c in string.whitespace})
                else:
                    char = '\n'
                    if '{' in temp_line:
                        char = '{'
                    contract_name = temp_line[:temp_line.index(char)].translate(
                        {ord(c): None for c in string.whitespace})

                if cont_name == contract_name:
                    contract_line = line_counter
                    while '{' not in uncommented_contract[contract_line]:
                        contract_line += 1
                    contract_info = [cont_name, cont, contract_line]

            # find_loops the constructor in the contract
            if "constructor" in line and c_line.index(
                    "constructor") == 0 and contract_name == cont_name and func_name == 'constructor':
                function_flag = True
                function_info = [func_name, function_vis, func_inputs, line_counter]

            # find_loops the matching function
            if "function " in line and c_line.index("function") == 0 and function_flag:
                break
            if "function " in line and c_line.index("function") == 0 and contract_name == cont_name:
                temp_line = line[line.index("function ") + 8:]
                if "(" in temp_line:
                    if function_flag:
                        break
                    function_name = temp_line[: temp_line.index("(")].translate(
                        {ord(c): None for c in string.whitespace})
                    if func_name == function_name:
                        function_flag = True
                        j_counter = 0
                        if ' pure ' in lines[line_counter + j_counter]:
                            lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' pure ', ' ')
                        if ' view ' in lines[line_counter + j_counter]:
                            lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' view ', ' ')
                        while '(' not in lines[line_counter + j_counter]:
                            if ' pure ' in lines[line_counter + j_counter]:
                                lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' pure ', ' ')
                            if ' view ' in lines[line_counter + j_counter]:
                                lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' view ', ' ')
                            j_counter += 1
                        if ' pure ' in lines[line_counter + j_counter]:
                            lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' pure ', ' ')
                        if ' view ' in lines[line_counter + j_counter]:
                            lines[line_counter + j_counter] = lines[line_counter + j_counter].replace(' view ', ' ')
                        if function_vis == 'external':
                            counter = line_counter
                            if ' payable[] calldata ' in lines[counter]:
                                lines[counter] = lines[counter].replace(' payable[] calldata ', '[] memory ')
                            if ' calldata ' in lines[counter]:
                                lines[counter] = lines[counter].replace(' calldata ', ' memory ')
                            while 'external' not in lines[counter]:
                                if ' payable[] calldata ' in lines[counter]:
                                    lines[counter] = lines[counter].replace(' payable[] calldata ', '[] memory ')
                                if ' calldata ' in lines[counter]:
                                    lines[counter] = lines[counter].replace(' calldata ', ' memory ')
                                counter += 1
                            lines[counter] = lines[counter].replace(' external', ' public')
                            i_counter = 0
                            while ')' not in lines[counter + i_counter]:
                                if 'calldata' in lines[counter + i_counter]:
                                    lines[counter + i_counter] = lines[counter + i_counter].replace(' calldata ',
                                                                                                    ' memory ')
                                i_counter += 1
                            if 'calldata' in lines[counter + i_counter]:
                                lines[counter + i_counter] = lines[counter + i_counter].replace(' calldata ',
                                                                                                ' memory ')

                        function_line = line_counter
                        function_info = [func_name, function_vis, func_inputs, function_line]

            # find_loops loops
            if function_flag:
                if ('for(' in c_line and (c_line.index('for') == 0 or line[line.index('for') - 1] == ' ')) or (
                        'while(' in c_line and (
                        c_line.index('while') == 0 or line[line.index('while') - 1] == ' ')) or (
                        'do{' in c_line and (c_line.index('do') == 0 or line[line.index('do') - 1] == ' ')):
                    inserted_new_lines = 0

                    loop_char = 'none'
                    next_line_flag = False

                    loop_list = list(line.split(" "))
                    for loop_l in loop_list:
                        if 'for' in loop_l:
                            loop_char = 'for'
                            break
                        elif 'while' in loop_l:
                            loop_char = 'while'
                            break
                        elif 'do' in loop_l:
                            loop_char = 'dowhile'

                        # For 'do-while' loops
                    if loop_char == 'dowhile':

                        if 'do{' in line and c_line.index('do{') + 2 != len(
                                c_line) - 1 and '}while(' not in c_line:  # 'do{xxx;' case
                            lines[line_counter] = line[:line.index('{') + 1]
                            lines.insert(line_counter + 1, line[line.index('{') + 1:])
                            inserted_new_lines += 1
                            line = lines[line_counter]

                        elif 'do{' in c_line and '}while(' in c_line and ');' in line:  # 'do{xxx;}while(--);'case
                            lines[line_counter] = line[:line.index('do{') + 3]
                            lines.insert(line_counter + 1, line[line.index('do') + 3:line.index('}while(')])
                            lines.insert(line_counter + 2, line[line.index('}'):])
                            inserted_new_lines += 2
                            line = lines[line_counter]

                        counter = line_counter
                        while '}while(' not in lines[counter].translate({ord(c): None for c in string.whitespace}):
                            counter += 1

                        t_index = lines[counter].translate({ord(c): None for c in string.whitespace}).index(
                            '}while(')
                        templine = ''
                        if 'do{' not in lines[counter].translate(
                                {ord(c): None for c in string.whitespace}) and t_index != 0 and '}while(' in lines[
                            counter].translate({ord(c): None for c in string.whitespace}) and ');' in \
                                lines[counter]:  # 'xxx;}while(--)'case
                            templine = lines[counter]
                            lines[counter] = lines[counter][:lines[counter].index('}')]
                            lines.insert(counter + 1, templine[templine.index('}'):])
                            inserted_new_lines += 1

                    elif (loop_char == 'for' or loop_char == 'while'):
                        if ')' in line:
                            if '{' not in line:
                                tt = lines[line_counter + 1]
                                print(tt)
                                if c_line.count('(') == c_line.count(')') and  c_line.rfind(')') != len(c_line) - 1:
                                    lines[line_counter] = line[:line.index(')') + 1] + ' { \n'
                                    lines.insert(line_counter + 1, line[line.index(')') + 1:])
                                    lines.insert(line_counter + 2, ' }\n')
                                    inserted_new_lines += 2
                                    line = lines[line_counter]
                                elif lines[line_counter + 1].translate(
                                        {ord(c): None for c in string.whitespace}) != '' and '{' not in lines[
                                    line_counter + 1]:
                                    lines[line_counter] = lines[line_counter][:-1] + ' { \n'
                                    line = lines[line_counter]
                                    lines.insert(line_counter + 2, ' }\n')
                                    inserted_new_lines += 1
                                elif lines[line_counter + 1].translate(
                                        {ord(c): None for c in string.whitespace}) == '{':
                                    next_line_flag = True


                        else:
                            count = line_counter + 1
                            lines[line_counter] = lines[line_counter][:-1]
                            while ')' not in lines[line_counter]:
                                lines[line_counter] += lines[count][:-1]
                                lines[count] = '// ' + lines[count]
                                count += 1
                            lines[line_counter] += '\n'
                            line = lines[line_counter]

                    start_of_loop = line_counter
                    end_of_loop = line_counter
                    counter = line_counter
                    while '{' not in lines[counter]:
                        counter += 1

                    stack = []
                    flag = False
                    for temp in lines[counter:]:
                        for c in range(len(temp)):
                            if temp[c] == '{':
                                stack.append(temp[c])
                                flag = True
                            elif temp[c] == '}':
                                stack.pop()
                            if flag and len(stack) < 1:
                                end_of_loop = counter
                                break
                        if len(stack) < 1:
                            break
                        counter += 1

                    loop_line = ''
                    counter = line_counter

                    if loop_char == 'dowhile':  # For 'do-while' loops
                        while '}while(' not in lines[counter].translate({ord(c): None for c in string.whitespace}):
                            counter += 1

                        if '}while(' in lines[counter].translate({ord(c): None for c in string.whitespace}):
                            loop_line = lines[counter]
                            lines[counter] = "//" + lines[counter]

                        temp_line = loop_line
                        condition = "1 == 0"

                        if ')' in temp_line:
                            temp_line = temp_line[temp_line.index(')'):]
                            loop_line = loop_line[:loop_line.index('(') + 1] + condition + temp_line

                        lines.insert(counter, loop_line)
                        inserted_new_lines += 1
                        line_counter += 1
                        end_of_loop += 1

                        loops_info.append([loop_char, start_of_loop, end_of_loop, inserted_new_lines, -1, []])

                    elif loop_char in {'for', 'while'}:
                        if '{' in line:
                            loop_line = line
                        while '{' not in lines[counter]:
                            loop_line += lines[counter]
                            lines[counter] = "//" + lines[counter]
                            counter += 1
                        lines[counter] = "//" + lines[counter]
                        l = lines[counter].translate({ord(c): None for c in string.whitespace})
                        if l.index('{') != len(l) - 1:
                            lines[counter] = lines[counter][:lines[counter].index('{') + 1]
                            lines.insert(counter + 1, lines[counter][lines[counter].index('{') + 1:])
                            inserted_new_lines += 1
                            line_counter += 1
                            end_of_loop += 1

                            while '}' not in lines[end_of_loop]:
                                end_of_loop += 1

                        temp_line = loop_line
                        condition = " 1 == 0 "
                        if loop_char == 'for':
                            if ';' not in temp_line:
                                return
                            temp_line = temp_line[temp_line.index(';') + 1:]
                            temp_line = temp_line[temp_line.index(';'):]
                            loop_line = loop_line[:loop_line.index(';') + 1] + condition + temp_line
                        else:
                            char = '}'
                            if ')' in temp_line:
                                char = ')'
                            if temp_line.count(char) > 1 and char == ')':
                                temp_line = temp_line[temp_line.rfind(char):]
                            else:
                                temp_line = temp_line[temp_line.index(char):]
                            loop_line = loop_line[:loop_line.index('(') + 1] + condition + temp_line
                        if next_line_flag:
                            loop_line = loop_line[:-1] + '{ \n'
                        lines.insert(start_of_loop, loop_line)
                        inserted_new_lines += 1
                        line_counter += 1
                        end_of_loop += 1

                        counter = end_of_loop
                        if lines[counter].translate({ord(c): None for c in string.whitespace}).index('}') != 0:
                            lines[counter] = lines[counter][:lines[counter].index('}')]
                            lines.insert(counter + 1, '}')
                            inserted_new_lines += 1
                            line_counter += 1
                            end_of_loop += 1

                        loops_info.append([loop_char, start_of_loop, end_of_loop, inserted_new_lines, -1, []])

        normal_loops = [i for i in range(len(loops_info))]
        nested_loops = []
        for loop in loops_info:
            for loop2 in loops_info[loops_info.index(loop) + 1:]:
                if loop[1] < loop2[1] < loop[2]:
                    loop2[4] = loops_info.index(loop)
                    loop[2] += loop2[3]
                    function_info
                    loop[5].append(loops_info.index(loop2))
                    if loops_info.index(loop) in normal_loops:
                        normal_loops.remove(loops_info.index(loop))
                    if loops_info.index(loop2) in normal_loops:
                        normal_loops.remove(loops_info.index(loop2))
                    if loop[4] == -1 and loops_info.index(loop) not in nested_loops:
                        nested_loops.append(loops_info.index(loop))
        return lines, contract_info, function_info, loops_info, normal_loops, nested_loops

    def get_new_contracts(self, input_list, contract_path, state_var_in_loop):
        new_contract, contract_info, function_info, loops_info, normal_loops, nested_loops = self.find_loop_info(
            input_list, contract_path)
        constructor = self.find_constructor(input_list[0], contract_path)
        contract_info.append(constructor)
        normal_loop_contracts = []
        for i in normal_loops:
            normal_loop_contracts.append(
                [self.modify_loop(new_contract, contract_info, function_info, loops_info[i], state_var_in_loop), i])
        nested_loops_contracts = []
        for i in nested_loops:
            nested_loops_contracts.append([i, new_contract, contract_info, function_info])
        return normal_loop_contracts, nested_loops_contracts, contract_info, loops_info

    def modify_contract(self, contract_path, new_contract):

        output_file = open(contract_path, "w")
        for line in new_contract:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

    def create_migrations(self, path):
        migration_folder = path + "migrations"
        try:
            os.mkdir(migration_folder)
        except OSError:
            print("Creation of the directory %s failed" % migration_folder)
        else:
            print("Successfully created the directory %s " % migration_folder)

    def modify_migrations(self, input_list):
        contract_name = input_list[0]
        migration_folder = self.folder_name + '/' + "migrations"

        text_list = ["const Migrations = artifacts.require(\"Migrations\");", "",
                     "module.exports = function(deployer) {",
                     "\t deployer.deploy(Migrations, {gas: "+str(self.env_gas_limit)+"});", "};"]
        output_file = open(migration_folder + '/' + "1_initial_migration.js", "w")

        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()
        constructor_input = ''
        input_string = ""
        if input_list[3]:
            inputs = input_list[3]
            counter = 1
            for inp in inputs:
                constructor_input += ', ' + "input" + str(counter)
                input_string += '\t let input' + str(counter) + ' = '
                if "[]" in inp:
                    if 'address' in inp:
                        temp = "'0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2'"
                        for num in range(500):
                            temp += ", '0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2'"
                        input_string += "[" + temp + "]"
                    else:
                        input_string += '[]'


                elif "[" in inp and "]" in inp:
                    inp_type = inp[:inp.index("[")]
                    s = inp[inp.index("[") + 1: inp.index("]")]
                    s = s.translate({ord(c): None for c in string.whitespace})
                    if s.isdigit():
                        inp_size = s
                    else:
                        inp_size = 5001
                    input_string += '['
                    for i in range(inp_size):
                        if i > 0:
                            input_string += ", "
                        if "int" in inp:
                            input_string += '1'
                        elif "address" in inp:
                            input_string += "'0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2'"
                        elif "byte" in inp:
                            input_string += "'0x00'"
                        elif "string" in inp:
                            input_string += "' '"
                        elif "bool" in inp:
                            input_string += 'true'
                    input_string += "]"

                elif "int" in inp:
                    input_string += '1'
                elif "address" in inp:
                    input_string += "'0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2'"
                elif "byte" in inp:
                    input_string += "'0x00'"
                elif "string" in inp:
                    input_string += "' '"
                elif "bool" in inp:
                    input_string += 'true'

                counter += 1
                input_string += '\n'

        text_list = ["const  TestContract = artifacts.require(\"" + contract_name + "\");", "",
                     "module.exports = function(deployer) {", str(input_string),
                     "\t deployer.deploy(TestContract " + str(constructor_input) + " );", "};"]

        output_file = open(migration_folder + '/' + "2_deploy_contracts.js", "w")
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

    def create_test_folder(self, path):
        test_folder = path + "test"
        try:
            os.mkdir(test_folder)
        except OSError:
            print("Creation of the directory %s failed" % test_folder)
        else:
            print("Successfully created the directory %s " % test_folder)

    def create_output_folder(self, path):
        temp_folder = path + "tempoutput"
        try:
            os.mkdir(temp_folder)
        except OSError:
            print("Creation of the directory %s failed" % temp_folder)
        else:
            print("Successfully created the directory %s " % temp_folder)

        test_file = temp_folder + '/' + "temp.txt"
        output_file = open(test_file, "w")
        text_list = ["temp"]
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

    # this function takes in the path to the solidity contract and returns the contract with no comments as a list
    def get_gas_left(self, it_count):
        inputs = list(self.f_info[2].split(","))
        function_name = 'getStateVarIn' + self.f_info[0]
        function_info = [function_name, inputs]

        new_contract = self.run_time_contract[0]
        change_line = self.run_time_contract[1]
        state_line = self.run_time_contract[2]
        change_state = self.run_time_contract[3]
        word = new_contract[change_line][new_contract[change_line].index('<='):]
        break_char = ';'
        if ';' not in word:
            break_char = ')'
            end = word.index(break_char)
        if ');' not in word and ';' in word:
            end = word.index(';')
        if ');' in word:
            end = word.index(');')
        word = word[:end]
        new_contract[change_line] = new_contract[change_line].replace(word, '<= ' + str(it_count))
        if state_line > 0 and '(' in new_contract[state_line]:
            w = new_contract[state_line][new_contract[state_line].index('('):new_contract[state_line].index(')') + 1]
            new_contract[state_line] = new_contract[state_line].replace(w, '(' + str(it_count + 1) + ')')
        for st in change_state:
            if '(' in new_contract[st[1]]:
                dig = new_contract[st[1]][
                    new_contract[st[1]].index('(') + 1 :new_contract[st[1]].index(')')].translate(
                    {ord(c): None for c in string.whitespace})
                if dig.isdigit():
                    w = new_contract[st[1]][
                        new_contract[st[1]].index('('):new_contract[st[1]].index(')') + 1]
                    new_contract[st[1]] = new_contract[st[1]].replace(w, '(' + str(it_count + 1) + ')')
            elif '=' in new_contract[st[1]]:
                dig = new_contract[st[1]][
                      new_contract[st[1]].index('=') + 1:new_contract[st[1]].index(';')].translate(
                    {ord(c): None for c in string.whitespace})
                if dig.isdigit():
                    w = new_contract[st[1]][
                        new_contract[st[1]].index('='):new_contract[st[1]].index(';') + 1]
                    new_contract[st[1]] = new_contract[st[1]].replace(w, '= ' + str(it_count + 1) + ';')
        counter = -1
        for cont_line in new_contract:
            counter += 1
            if '.push(threshold_new_var' in cont_line:
                temp = cont_line[:-1]
                new_word = temp[temp.index(';') + 1:]
                new_word = new_word[:new_word.index(';') + 1]
                temp = temp[: temp.index(';') + 1]
                while temp.count(';') <= it_count + 2:
                    temp += new_word
                temp += ' \n'
                new_contract[counter] = temp

        self.modify_contract(self.env_contract_path, new_contract)
        self.modify_test_folder(self.c_info, function_info, it_count)
        return self.get_gas_results(self.env_contract_folder, self.env_output)

    def get_gas_results(self, contract_folder, output_file_path):
        command = "cd " + contract_folder + " ;truffle" + " test 2>&1 | tee " + output_file_path
        os.system(command)
        output = -3
        f = open(contract_folder + '/' + output_file_path, "r")
        lines = f.readlines()
        for line in lines:
            if 'The number is (Tested:' in line:
                output = int(line[line.index('Tested: ') + 7:line.index(", Against")].translate(
                    {ord(c): None for c in string.whitespace}))
                break
            elif 'out of gas' in line:
                output = -1
                break
            elif 'Reason given:' in line:
                output = -5
                break
            elif 'VM Exception while processing transaction: revert' in line:
                output = -2
                break
            elif 'not yet supported' in line or 'Missing implementation:' in line:
                output = -4
                break
            elif 'Compilation failed' in line:
                output = -3
                break

        f.close()
        return output

    def get_results(self, contract_folder, output_file_path):
        command = "cd " + contract_folder + " ;truffle" + " test 2>&1 | tee " + output_file_path
        os.system(command)
        original_gas = 3
        first_iteration_gas = -3
        second_iteration_gas = -3
        key = ''
        not_supported = ['Error: while migrating', 'Stack too deep, try removing local variables.',
                         'TypeError: Trying to create an instance of an abstract contract', 'unresolved libraries',
                         'Contract with internal constructor cannot', 'Nested dynamic arrays not implemented here']
        not_supported_flag = False
        print("contract_folder: ", contract_folder)
        f = open(contract_folder + '/' + output_file_path, "r")  #
        if f.mode == 'r':
            line_counter = -1
            lines = f.readlines()
            for line in lines[:len(lines) - 1]:
                line_counter += 1
                next_line = lines[line_counter + 1]
                for er in not_supported:
                    if er in line:
                        not_supported_flag = True
                        break
                if not_supported_flag:
                    original_gas = -30
                    break
                if 'out of gas' in line:
                    original_gas = -10
                    break
                elif 'Contract with internal constructor cannot be created directly' in line or 'DeclarationError: Undeclared identifier' in line:
                    original_gas = -50
                    break
                elif 'TypeError:' in line:
                    original_gas = -60
                    break
                elif "Compilation failed" in line:
                    original_gas = -20
                    break
                if '3 passing' in line:
                    original_gas = -40
                    break
                if 'testInsertInput1:' in line:
                    if 'The number is (Tested:' in next_line:
                        original_gas = int(
                            next_line[next_line.index('Tested: ') + 7:next_line.index(", Against")].translate(
                                {ord(c): None for c in string.whitespace}))
                    elif 'out of gas' in next_line:
                        original_gas = -10
                    elif 'VM Exception while processing transaction: revert' in next_line:
                        original_gas = -2
                elif 'testInsertInput2:' in line:
                    if 'The number is (Tested:' in next_line:
                        first_iteration_gas = int(
                            next_line[next_line.index('Tested: ') + 7:next_line.index(", Against")].translate(
                                {ord(c): None for c in string.whitespace}))
                    elif 'out of gas' in next_line:
                        first_iteration_gas = -10
                    elif 'VM Exception while processing transaction: revert' in next_line:
                        first_iteration_gas = -2

                elif 'testInsertInput3:' in line:
                    if 'The number is (Tested:' in next_line:
                        second_iteration_gas = int(
                            next_line[next_line.index('Tested: ') + 7:next_line.index(", Against")].translate(
                                {ord(c): None for c in string.whitespace}))
                    elif 'out of gas' in next_line:
                        second_iteration_gas = -10
                    elif 'VM Exception while processing transaction: revert' in next_line:
                        second_iteration_gas = -2
                    break

        f.close()

        estimated = -1
        if original_gas > 0 and first_iteration_gas > 0 and second_iteration_gas > 0:
            estimated = 1 + int((original_gas - first_iteration_gas) / second_iteration_gas)

        if first_iteration_gas < 1:
            first_iteration_gas = 0
        if second_iteration_gas < 1:
            second_iteration_gas = 1

        if original_gas <= -10:
            estimated = original_gas

        return estimated, original_gas, first_iteration_gas, second_iteration_gas

    def modify_test_folder(self, contract_info, function_info, it_counter=2, type='run'):
        test_folder = self.folder_name + '/' + "test"
        function_name = function_info[0]
        function_input_list = function_info[1]
        contract_name = contract_info[0]
        constructor_input = contract_info[3]
        constructor_string = ""

        counter = 1
        constructor_inps = ''
        if constructor_input != [''] and 'constructor' not in function_name.lower():
            for inp in constructor_input:
                input_name = "c_input" + str(counter)
                if ']' in inp:
                    inp = inp[:inp.index(']') + 1]
                if counter > 1:
                    constructor_inps += ", "
                constructor_inps += input_name
                if "[]" in inp:
                    t = ''
                    if ' memory' not in inp:
                        t = ' memory '
                    constructor_string += "\t\t " + inp + t + input_name + " = new " + inp + "(" + str(4) + ");"

                elif "[" in inp and "]" in inp:
                    inp_type = inp[:inp.index("[")]
                    inp_size = int(inp[inp.index("[") + 1: inp.index("]")])
                    t = ''
                    if ' memory' not in inp:
                        t = ' memory '
                    constructor_string += "\t\t " + inp + t + input_name + " = ["
                    for i in range(inp_size):
                        if i > 0:
                            constructor_string += ", "
                        if "int" in inp_type:
                            constructor_string += inp_type + "(1)"
                        elif "address" in inp_type:
                            constructor_string += inp_type + "(0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2)"
                        elif "byte" in inp_type:
                            constructor_string += inp_type + "(0x00)"
                        elif "string" in inp_type:
                            constructor_string += "\"a\""
                        elif "bool" in inp_type:
                            constructor_string += "true"
                    constructor_string += "];"

                elif "int" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += str(4) + ';'
                elif "address" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2;"
                elif "byte" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "0x00;"
                elif "string" in inp:
                    if "memory" not in inp:
                        inp += " memory "
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "\" \";"
                elif "bool" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "true;"

                constructor_string += "\n"
                counter += 1
        input_string = ""
        counter = 1
        function_inputs = ''
        if function_input_list != ['']:
            for inp in function_input_list:
                input_name = "input" + str(counter)
                if counter > 1:
                    function_inputs += ", "
                function_inputs += input_name
                if "[]" in inp:
                    t = ''
                    if ' memory' not in inp:
                        t = ' memory '
                    input_string += "\t\t " + inp + t + input_name + " = new " + inp + "(" + str(
                        it_counter + 1) + ");"

                elif "[" in inp and "]" in inp:
                    inp_type = inp[:inp.index("[")]
                    inp_size = int(inp[inp.index("[") + 1: inp.index("]")])
                    input_string += "\t\t " + inp + 'memory ' + input_name + " = ["
                    for i in range(inp_size):
                        if i > 0:
                            input_string += ", "
                        if "int" in inp_type:
                            input_string += inp_type + "(1)"
                        elif "address" in inp_type:
                            input_string += inp_type + "(0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2)"
                        elif "byte" in inp_type:
                            input_string += inp_type + "(0x00)"
                        elif "string" in inp_type:
                            input_string += "\"a\""
                        elif "bool" in inp_type:
                            input_string += "true"
                    input_string += "];"

                elif "int" in inp:
                    input_string += "\t\t " + inp + " " + input_name + " = "
                    input_string += str(it_counter + 1) + ';'
                elif "address" in inp:
                    input_string += "\t\t " + inp + " " + input_name + " = "
                    input_string += "0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2;"
                elif "byte" in inp:
                    input_string += "\t\t " + inp + " " + input_name + " = "
                    input_string += "0x00;"
                elif "string" in inp:
                    if "memory" not in inp:
                        inp += " memory "
                    input_string += "\t\t " + inp + " " + input_name + " = "
                    input_string += "\" \";"
                elif "bool" in inp:
                    input_string += "\t\t " + inp + " " + input_name + " = "
                    input_string += "true;"

                input_string += "\n"
                counter += 1
        if 'constructor' in function_name.lower():
            constructor_inps = function_inputs

        if type == 'run':

            text_list = ["pragma solidity >=0.4.25 <0.7.0;", "", "", "import \"truffle/Assert.sol\";",
                         "import \"truffle/DeployedAddresses.sol\";", "import \"../contracts/" + self.file_name + "\";",
                         "",
                         "contract Test" + contract_name + " {", "", "\t function testInsertInput() public {",
                         constructor_string, input_string,
                         "\t\t" + contract_name + " con = new " + contract_name + "(" +
                         constructor_inps + ");", "\t\t uint gas_left = con." + function_name + "(" +
                         function_inputs + ");", "\t\t Assert.equal(gas_left, 0, \"The number is\");", "\t }", "}"]
        else:
            text_list = ["pragma solidity >=0.4.25 <0.7.0;", "", "", "import \"truffle/Assert.sol\";",
                         "import \"truffle/DeployedAddresses.sol\";", "import \"../contracts/" + self.file_name + "\";",
                         "",
                         "contract Test" + contract_name + " {", "", "\t function testInsertInput1() public {",
                         constructor_string, input_string,
                         "\t\t" + contract_name + " con = new " + contract_name + "(" +
                         constructor_inps + ");", "\t\t uint[] memory val = con." + function_name + "(" +
                         function_inputs + ");", "\t\t Assert.equal(val[0], 0, \"The number is\");", "\t }",
                         "\t function testInsertInput2() public {", constructor_string, input_string,
                         "\t\t" + contract_name + " con = new " + contract_name + "(" +
                         constructor_inps + ");", "\t\t uint[] memory val = con." + function_name + "(" +
                         function_inputs + ");", "\t\t Assert.equal(val[1], 0, \"The number is\");", "\t }",
                         "\t function testInsertInput3() public {", constructor_string, input_string,
                         "\t\t" + contract_name + " con = new " + contract_name + "(" +
                         constructor_inps + ");", "\t\t uint[] memory val = con." + function_name + "(" +
                         function_inputs + ");", "\t\t Assert.equal(val[2], 0, \"The number is\");", "\t }",

                         "}"]

        test_file = test_folder + '/' + "Test" + self.file_name
        output_file = open(test_file, "w")
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()

    def modify_test_folder_fuzzer(self, input_list, constructor_input):
        test_folder = self.folder_name + '/' + "test"
        contract_name = input_list[0]
        function_sig = input_list[1]
        inputs_to_fuzz = input_list[2]
        function_name = function_sig[:function_sig.index('(')]
        function_inputs = function_sig[function_sig.index('(') + 1: function_sig.index(')')]

        constructor_string = ""

        counter = 1
        constructor_inps = ''
        if constructor_input != [''] and 'constructor' not in function_name.lower():
            for inp in constructor_input:
                input_name = "c_input" + str(counter)
                if ']' in inp:
                    inp = inp[:inp.index(']') + 1]
                if counter > 1:
                    constructor_inps += ", "
                constructor_inps += input_name
                if "[]" in inp:
                    t = ''
                    if ' memory' not in inp:
                        t = ' memory '
                    constructor_string += "\t\t " + inp + t + input_name + " = new " + inp + "(" + str(1) + ");"

                elif "[" in inp and "]" in inp:
                    inp_type = inp[:inp.index("[")]
                    inp_size = int(inp[inp.index("[") + 1: inp.index("]")])
                    t = ''
                    if ' memory' not in inp:
                        t = ' memory '
                    constructor_string += "\t\t " + inp + t + input_name + " = ["
                    for i in range(inp_size):
                        if i > 0:
                            constructor_string += ", "
                        if "int" in inp_type:
                            constructor_string += inp_type + "(1)"
                        elif "address" in inp_type:
                            constructor_string += inp_type + "(0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2)"
                        elif "byte" in inp_type:
                            constructor_string += inp_type + "(0x00)"
                        elif "string" in inp_type:
                            constructor_string += "\"a\""
                        elif "bool" in inp_type:
                            constructor_string += "true"
                    constructor_string += "];"

                elif "int" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += str(1) + ';'
                elif "address" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2;"
                elif "byte" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "0x00;"
                elif "string" in inp:
                    if "memory" not in inp:
                        inp += " memory "
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "\" \";"
                elif "bool" in inp:
                    constructor_string += "\t\t " + inp + " " + input_name + " = "
                    constructor_string += "true;"

                constructor_string += "\n"
                counter += 1

        fuzz_list = []
        function_input_list = []
        if ',' in function_inputs:
            function_input_list = function_inputs.split(',')
        else:
            function_input_list = [function_inputs]

        input_string = ""
        function_inputs = ""
        counter = 1
        for inp in function_input_list:
            input_name = "input" + str(counter)
            if (counter - 1) in inputs_to_fuzz:
                fuzz_list.append([input_name, inp, str(counter - 1)])

            if counter > 1:
                function_inputs += ", "
            function_inputs += input_name
            if "[]" in inp:
                input_string += "\t\t " + inp + " memory " + input_name + " = new " + inp + "(1);"

            elif "[" in inp and "]" in inp:
                inp_type = inp[:inp.index("[")]
                inp_size = int(inp[inp.index("[") + 1: inp.index("]")])
                input_string += "\t\t " + inp + " memory " + input_name + " = ["
                for i in range(inp_size):
                    if i > 0:
                        input_string += ", "
                    if "int" in inp_type:
                        input_string += inp_type + "(1)"
                    elif "address" in inp_type:
                        input_string += inp_type + "(0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2)"
                    elif "byte" in inp_type:
                        input_string += inp_type + "(0x00)"
                    elif "string" in inp_type:
                        input_string += "\"a\""
                    elif "bool" in inp_type:
                        input_string += "true"
                input_string += "];"

            elif "int" in inp:
                input_string += "\t\t " + inp + " " + input_name + " = "
                input_string += "1;"
            elif "address" in inp:
                input_string += "\t\t " + inp + " " + input_name + " = "
                input_string += "0x87cEF29C3759950Fbb0d61460e81772D29CC0Ad2;"
            elif "byte" in inp:
                input_string += "\t\t " + inp + " " + input_name + " = "
                input_string += "0x00;"
            elif "string" in inp:
                if "memory" not in inp:
                    inp += " memory "
                input_string += "\t\t " + inp + " " + input_name + " = "
                input_string += "\" \";"
            elif "bool" in inp:
                input_string += "\t\t " + inp + " " + input_name + " = "
                input_string += "true;"

            input_string += "\n"
            counter += 1

        call_function = "\t\t con." + function_name + "(" + function_inputs + ");"
        if 'constructor' in function_name.lower():
            constructor_inps = function_inputs
            call_function = ""

        text_list = ["pragma solidity >=0.4.25 <0.7.0;", "", "", "import \"truffle/Assert.sol\";",
                     "import \"truffle/DeployedAddresses.sol\";", "import \"../contracts/" + self.file_name + "\";", "",
                     "contract Test" + contract_name + " {", "", "\t function testInsertInput() public {",
                     constructor_string, input_string,
                     "\t\t" + contract_name + " con = new " + contract_name + "(" +
                     constructor_inps + ");", call_function, "\t\t Assert.equal(gasleft(), 0, \"The remaining gas!\");",
                     "\t }", "}"]

        test_file = test_folder + '/' + "Test" + self.file_name
        output_file = open(test_file, "w")
        for line in text_list:
            # write line to output file
            output_file.write(line)
            output_file.write("\n")
        output_file.close()
        return fuzz_list

    def find_nested_loop_order(self, all_loops):
        nested_loop = []
        for parent in all_loops:
            nested_loop.append([])
            for child in parent[5]:
                if all_loops[child][4] == all_loops.index(parent):
                    nested_loop[all_loops.index(parent)].append(child)
        return nested_loop

    def run_all(self):
        try:
            os.mkdir(self.folder_name)
        except OSError:
            print("Creation of the directory %s failed" % self.folder_name)
        else:
            print("Successfully created the directory %s " % self.folder_name)

        self.create_config()
        self.create_migrations(self.folder_name + '/')
        self.create_test_folder(self.folder_name + '/')
        self.create_output_folder(self.folder_name + '/')
        return self.create_contract_folder()
