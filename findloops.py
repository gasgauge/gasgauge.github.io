import os
import shutil
import glob
import string

FIXED = 'F'
LOCAL = 'L'
INPUT = 'I'
STATE = 'S'
FIXEDLOCAL = 'FL'
PUBLIC = "PB"
PRIVATE = "PR"
EXTERNAL = "EX"


class FindLoops:
    def __init__(self, contract_path, original_name, file_name, temp_output_path, output_file, solc_use):
        self.contract_path = contract_path
        self.original_name = original_name
        self.file_name = file_name
        self.temp_output_path = temp_output_path
        self.output_file = output_file
        self.solc_use = solc_use
        self.state_variables = []
        self.func_sum = []
        self.general_loops = []
        self.local_variables = []
        self.func_info = []
        self.variable_dependency = []
        self.input_variables = []

    def run_command_with_output(self, command, path, output_file):
        cmd = self.solc_use + " " + command
        os.system(cmd)
        f = open(path + '/' + output_file, "r")
        return f.readlines()

    def make_local_variables(self):
        command = "cd " + self.temp_output_path + "; slither " + self.file_name + " --print cfg"
        cmd = self.solc_use + " " + command

        os.system(cmd)
        loops = []
        local_variables = []
        error = True
        for filename in glob.glob(os.path.join(self.temp_output_path, '*.dot')):
            error = False
            file = open(filename, 'r')  # READING DOT FILE
            temp = file.name[:file.name.index(".dot")]
            temp = temp[::-1]
            function_name = temp[:temp.index('-')]
            function_name = function_name[::-1]
            temp = temp[temp.index('-') + 1:]
            char = '/'
            if '-' in temp:
                char = '-'
            cont_name = temp[:temp.index(char)]
            cont_name = cont_name[::-1]
            lines = file.readlines()

            loop_flag = False
            variable_flag = False
            previous_line = ""

            for line in lines:
                if "Type: IF_LOOP" in line:
                    loop_flag = True
                if loop_flag and "EXPRESSION:" in previous_line:
                    c_line = line.translate({ord(c): None for c in string.whitespace})
                    # 'epochIdx <= endEpoch && (remainingSupplyCurrency != 0 || remainingRedeemToken != 0)
                    condition_flag = False
                    counter = 0
                    loop_vars = []
                    condition_chars = ['(', ')', '<', '>', '=', '&', '!', '|', '+', '-', '%', '^', '*', '/', '~']
                    temp_c_line = c_line + '~'
                    while counter < len(c_line) + 1 and len(temp_c_line) > 1:
                        for c in temp_c_line:
                            if c in condition_chars:
                                condition_var = temp_c_line[:temp_c_line.index(c)]
                                if len(temp_c_line) > 1:
                                    temp_c_line = temp_c_line[temp_c_line.index(c) + 1:]
                                else:
                                    temp_c_line = ''
                                if condition_var != '' and condition_var not in loop_vars:
                                    loop_vars.append(condition_var)
                        counter += 1
                    if not loop_vars:
                        loop_vars.append(c_line)

                    visibility = ''
                    for func in self.func_sum:
                        if func[0] == cont_name and func[1] == function_name:
                            visibility = func[2]
                    flag = False
                    for loop in loops:
                        if loop[0] == cont_name and loop[1] == function_name:
                            loop[3].append(c_line)
                            for l in loop_vars:
                                loop[4].append(l)
                            flag = True
                            break
                    if not flag:
                        loops.append([cont_name, function_name, visibility, [c_line], loop_vars])

                if "]" in line and loop_flag:
                    loop_flag = False

                if "Type: NEW VARIABLE " in line:
                    variable_flag = True

                if variable_flag and "EXPRESSION:" in previous_line:
                    var = line[:line.index('=') - 1]
                    rem_line = line[line.index('=') + 2:]
                    var2 = []
                    while " " in rem_line:
                        var2.append(rem_line[:rem_line.index(" ")])
                        rem_line = rem_line[rem_line.index(' ') + 1:]
                    var2.append(rem_line[:rem_line.index('\n')])

                    local_variables.append([cont_name, function_name, var, var2])

                if "]" in line and variable_flag:
                    variable_flag = False

                previous_line = line

        return loops, local_variables, error

    def make_function_summary(self):
        command = "cd " + self.temp_output_path + "; slither " + self.file_name + " --print function-summary 2>&1 | tee " + self.output_file
        lines = self.run_command_with_output(command, self.temp_output_path, self.output_file)

        cont_name = ""
        func_sum = []
        func_flag = False
        previous_line = ""
        for line in lines:
            if previous_line.translate({ord(c): None for c in string.whitespace}) == "INFO:Printers:":
                cont_name = line.translate({ord(c): None for c in string.whitespace})[
                            8:len(line.translate({ord(c): None for c in string.whitespace}))]

            if func_flag and line[:2] == "+-":
                func_flag = False

            if func_flag:
                c_line = line.translate({ord(c): None for c in string.whitespace})[
                         1:len(line.translate({ord(c): None for c in string.whitespace})) - 1]
                function_name = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                visibility = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                modifiers = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                read = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                write = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                internal_calls = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                external_calls = c_line
                if function_name != "":
                    func_sum.append(
                        [cont_name, function_name, visibility, write])
            if line[:2] == "+-" and previous_line.translate({ord(c): None for c in
                                                             string.whitespace}) == "|Function|Visibility|Modifiers" \
                                                                                    "|Read|Write|InternalCalls" \
                                                                                    "|ExternalCalls|":
                func_flag = True
            previous_line = line
        return func_sum

    def find_var_type(self, loop, var_name, checked):
        # print(loop)
        # print(var_name)
        # print(checked)
        # If the loop bound is a fixed number
        cont_name = loop[0]
        func_name = loop[1]
        if var_name.isnumeric():
            if var_name not in checked:
                checked.append(var_name)
            return var_name, FIXED, []
        if '.' in var_name:
            var_name = var_name[:var_name.index('.')]

        # If the loop bound is an input variable
        for input_v in self.input_variables:
            for v in input_v[2]:
                f_name = func_name
                in_f_name = input_v[1]
                if "(" in f_name:
                    f_name = f_name[:f_name.index("(")]
                if "(" in in_f_name:
                    in_f_name = in_f_name[:in_f_name.index("(")]

                if input_v[0] == cont_name and in_f_name == f_name and v[0] == var_name:
                    if var_name not in checked:
                        checked.append(var_name)
                    return var_name, INPUT, v[1]

        # If the loop bound is a state variable
        for state_v in self.state_variables:
            if state_v[0] == cont_name and state_v[1] == var_name:
                temp_func = []
                for f in self.func_sum:
                    if var_name in f[3] and f[0] == cont_name:
                        temp_func.append(f[1])
                if var_name not in checked:
                    checked.append(var_name)
                return var_name, STATE, temp_func

        # IF the loop bound is a local variable with dependencies
        for var_dep in self.variable_dependency:
            if var_dep[0] == cont_name and var_dep[1] == func_name and var_dep[2] == var_name:
                temp_func = []
                for var_d in var_dep[3]:
                    if var_d != var_name and var_d not in checked:
                        if var_name not in checked:
                            checked.append(var_name)
                        v_name, v_type, f_dep = self.find_var_type(loop, var_d, checked)
                        temp_func.append([var_d, v_type, f_dep])

                if var_name not in checked:
                    checked.append(var_name)
                return var_name, LOCAL, temp_func

        # IF the loop bound is a local variable with a fixed number
        for var_dep in self.local_variables:
            if var_dep[0] == cont_name and var_dep[1] == func_name and var_dep[2] == var_name:
                temp_func = [FIXED, var_dep[3]]
                if var_name not in checked:
                    checked.append(var_name)
                return var_name, FIXEDLOCAL, temp_func
        return 'NA', 'NA', []

    def find_input_var(self):
        contract_path = self.contract_path + self.original_name

        lines = self.remove_comments(contract_path)
        contract_name = ""
        function_inputs = []
        counter = -1
        for line in lines:
            counter += 1
            if "contract " in line or "interface " in line:
                co = "contract "
                if "contract " not in line and "interface " in line:
                    co = "interface "
                if "//" in line and line.index("//") < line.index(co) or (
                        "*" in line and line.index("*") < line.index(co)):
                    continue
                if "require(" in line:
                    continue
                flag = False
                for c in ["'", '"', '(', '[']:
                    if c in line:
                        if line.index(c) < line.index(co):
                            flag = True
                            break
                if flag:
                    continue
                if ("/*" in line and line.index("/*") > line.index(co)) or "/*" not in line:
                    temp_line = line[line.index(co) + len(co):]
                    if " is" in temp_line:
                        temp_line = temp_line[: temp_line.index(" is")]
                        contract_name = temp_line.translate({ord(c): None for c in string.whitespace})
                    else:
                        char = '\n'
                        if '{' in temp_line:
                            char = '{'
                        if char not in temp_line:
                            print("error")
                        contract_name = temp_line[: temp_line.index(char)]
                        contract_name = contract_name.translate({ord(c): None for c in string.whitespace})
            if "library " in line:
                if "//" in line and line.index("//") < line.index("library ") or (
                        "*" in line and line.index("*") < line.index("library ")):
                    continue
                if ("/*" in line and line.index("/*") > line.index("library ")) or "/*" not in line:
                    temp_line = line[line.index("library ") + 8:]
                    if " is" in temp_line:
                        temp_line = temp_line[: temp_line.index(" is")]
                        contract_name = temp_line.translate({ord(c): None for c in string.whitespace})
                    else:
                        char = '\n'
                        if '{' in temp_line:
                            char = '{'
                        contract_name = temp_line[: temp_line.index(char)]
                        contract_name = contract_name.translate({ord(c): None for c in string.whitespace})

            if "function " in line or "constructor" in line:
                f_char = 'function '
                if f_char not in line:
                    f_char = "constructor"
                if ("//" in line and line.index("//") < line.index(f_char)) or (
                        "*" in line and line.index("*") < line.index(f_char)):
                    continue
                if ("/*" in line and line.index("/*") < line.index(f_char)) or "/*" not in line:
                    temp_line = line[line.index(f_char) + len(f_char):]
                    if "(" in temp_line:
                        function_name = temp_line[: temp_line.index("(")]
                        function_name = function_name.translate({ord(c): None for c in string.whitespace})
                        for func in self.func_info:
                            func_name = func[1]
                            if func[0] == contract_name and func_name[:func_name.index("(")] == function_name:
                                function_name = func[1]
                                break
                        if f_char == "constructor":
                            function_name = 'constructor'
                        temp_line = line[line.index("(") + 1:]
                        if ")" not in temp_line:
                            j = 1
                            while ")" not in temp_line:
                                next_line = lines[counter + j]
                                while next_line[0] == " ":
                                    next_line = next_line[1:]
                                temp_line += next_line
                                if '\n' in temp_line:
                                    temp_line = temp_line.replace('\n', "")
                                j += 1
                        inputs = temp_line[:temp_line.index(")")]
                        temp_list = []
                        if inputs.translate({ord(c): None for c in string.whitespace}) != "":
                            temp_list = list(inputs.split(","))
                        index = 0
                        function_input_list = []
                        for inp in temp_list:
                            var_type = ""
                            var_name = ""
                            temp = inp

                            temp = temp[::-1]
                            if temp != '':
                                while temp[0] == " ":
                                    temp = temp[1:]
                            if " " not in temp:
                                temp = '0 ' + temp
                            var_name = temp[:temp.index(" ")]
                            temp = temp[temp.index(" ") + 1:]
                            if temp == "":
                                temp = '0'
                            while temp[0] == " ":
                                temp = temp[1:]
                            var_name = var_name[::-1]
                            var_name = var_name.translate({ord(c): None for c in string.whitespace})
                            temp = temp[::-1]
                            while temp[0] == " ":
                                temp = temp[1:]
                            var_type = temp

                            function_input_list.append([var_name, index, var_type])
                            index += 1
                        function_inputs.append([contract_name, function_name, function_input_list])

        return function_inputs

    def make_variable_dependency(self):
        command = "cd " + self.temp_output_path + "; slither " + self.file_name + " --print data-dependency 2>&1 | tee " + self.output_file
        lines = self.run_command_with_output(command, self.temp_output_path, self.output_file)
        cont_name = ""
        function_name = ""
        input_var = []
        variable_dependency = []
        input_var_flag = False
        prev = prev_prev = previous_line = ""
        for line in lines:
            if previous_line.translate({ord(c): None for c in string.whitespace}) == "INFO:Printers:" or (
                    previous_line[:2] == "+-" and line[:9] == "Contract "):
                cont_name = line.translate({ord(c): None for c in string.whitespace})[
                            8:len(line.translate({ord(c): None for c in string.whitespace}))]
            if "Function " in previous_line and line[0:2] == "+-":
                function_name = previous_line.translate({ord(c): None for c in string.whitespace})[8:]

            if input_var_flag and line[:2] == "+-":
                input_var_flag = False

            if input_var_flag:
                c_line = line.translate({ord(c): None for c in string.whitespace})[
                         1:len(line.translate({ord(c): None for c in string.whitespace})) - 1]
                variable_name = c_line[0:c_line.index("|")]
                c_line = c_line[c_line.index("|") + 1:]
                dependency = c_line
                if dependency == "[]" and '.' not in variable_name and variable_name != "":
                    in_flag = True
                    for v in self.local_variables:
                        if cont_name == v[0] and function_name == v[1] and variable_name == v[2]:
                            in_flag = False
                            break
                    if in_flag:
                        input_var.append([cont_name, function_name, variable_name])
                else:
                    dependency_list = dependency
                    if dependency != "[]":
                        dependency_list = dependency[1:len(dependency) - 1].replace("'", "")
                        dependency_list = list(dependency_list.split(","))
                    variable_dependency.append([cont_name, function_name, variable_name, dependency_list])
            if line[:2] == "+-" and previous_line.translate(
                    {ord(c): None for c in
                     string.whitespace}) == "|Variable|Dependencies|" and "Function " in prev_prev:
                input_var_flag = True
            prev_prev = prev
            prev = previous_line
            previous_line = line
        return input_var, variable_dependency

    def make_state_variable_list(self):
        command = "cd " + self.temp_output_path + "; slither " + self.file_name + " --print variable-order 2>&1 | tee " + self.output_file
        lines = self.run_command_with_output(command, self.temp_output_path, self.output_file)

        state_variables = []
        state_flag = False
        previous_line = ""
        for line in lines:
            if state_flag and line[:2] == "+-":
                state_flag = False

            if state_flag:
                c_line = line.translate({ord(c): None for c in string.whitespace})[1:]
                c_name = c_line[0:c_line.index(".")]
                v_name = c_line[c_line.index(".") + 1: c_line.index("|")]
                v_type = c_line[c_line.index("|") + 1: len(c_line) - 1]
                if '|' in v_type:
                    v_type = v_type[:v_type.index('|')]
                state_variables.append([c_name, v_name, v_type])

            if line[:2] == "+-" and previous_line.translate({ord(c): None for c in string.whitespace})[
                                    :len("|Name|Type|")] == "|Name|Type|":
                state_flag = True
            previous_line = line

        return state_variables

    def find_loop_bound_type(self, loop_bound, loop, state_in_loop, input_in_loop):
        contract_name = loop[0]
        function_name = loop[1]
        function_name = function_name[:function_name.index('(')]
        for var in loop_bound:
            if var[1] == 'S':
                s_var = var[0]
                if '.' in s_var:
                    s_var = s_var[:s_var.index('.')]
                for s in self.state_variables:
                    if contract_name == s[0] and s_var == s[1] and s not in state_in_loop and s[2] != 'address':
                        state_in_loop.append(s)
                        break
                flag = False
                for inp in self.variable_dependency:
                    f_name = inp[1]
                    if '(' in f_name:
                        f_name = f_name[:f_name.index('(')]
                    if inp[0] == contract_name and f_name == function_name and '.' in inp[2]:
                        new_var = inp[2]
                        if new_var[:new_var.index('.')] == contract_name and new_var[new_var.index('.') + 1:] == s_var:
                            flag = True
                            for d_v in inp[3]:
                                for i in self.input_variables:
                                    fun_name = i[1]
                                    if '(' in fun_name:
                                        fun_name = fun_name[:fun_name.index('(')]
                                    if contract_name == i[0] and f_name == fun_name:
                                        for variable in i[2]:
                                            if variable[0] == d_v and variable not in input_in_loop and variable[2] != 'address':
                                                input_in_loop.append(variable)
                                                break
                    if flag:
                        break

            if var[1] == "I":
                i_var = var[0]
                if '.' in i_var:
                    i_var = i_var[:i_var.index('.')]
                for i in self.input_variables:
                    f_name = i[1]
                    if '(' in f_name:
                        f_name = f_name[:f_name.index('(')]
                    if contract_name == i[0] and f_name == function_name and i not in input_in_loop:
                        for v in i[2]:
                            if v[0] == i_var and v[2] != 'address':
                                input_in_loop.append(v)
                                break
            if var[1] == 'L' and var[2]:
                self.find_loop_bound_type(var[2], loop, state_in_loop, input_in_loop)
        return state_in_loop, input_in_loop

    ########################################

    def make_var_type(self, loop):
        var_type_list = []
        for var in loop[4]:
            var_type_list.append(self.find_var_type(loop, var, []))

        return var_type_list

    def remove_comments(self, contract_path):

        file = open(contract_path, "r")
        lines = file.readlines()
        new_contract = []
        c_flag1 = False
        c_flag2 = False
        for line in lines:
            new_line = line
            if '//' in line:
                new_line = line[:line.index('//')] + '\n'
            if '/**' in line:
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

        return new_contract

    def find_loops(self):

        try:
            os.makedirs(self.temp_output_path)
        except OSError:
            print("Creation of the directory %s failed" % self.temp_output_path)
        else:
            print("Successfully created the directory %s " % self.temp_output_path)
        shutil.copy(self.contract_path + self.original_name, self.temp_output_path + '/' + self.file_name,
                    follow_symlinks=True)
        self.state_variables = self.make_state_variable_list()
        self.func_sum = self.make_function_summary()

        self.general_loops, self.local_variables, error = self.make_local_variables()
        self.func_info, self.variable_dependency = self.make_variable_dependency()
        self.input_variables = self.find_input_var()
        return self.general_loops, error
