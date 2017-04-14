
import math
import os
SPACER = None
QUIT_OPTION = 'Done'
INVALID_CHOICE = (-1)

def clear_screen():
    os.system(('cls' if (os.name == 'nt') else 'clear'))

class Menu(object, ):

    def __init__(self, heading, choices, choice_heading, prompt):
        self.heading = heading
        self.choices = choices
        self.choice_heading = choice_heading
        self.prompt = prompt

    def __str__(self):
        if self.heading:
            print ('%s\n' % self.heading)
        if self.choice_heading:
            settings = [self.choice_heading]
            has_heading = True
        else:
            settings = []
            has_heading = False
        settings += self._get_table_data()
        settings.append([SPACER])
        settings.append([QUIT_OPTION])
        final_string = self._draw_table(settings, has_heading)
        return final_string

    def show(self, default=None):
        print self
        choice = raw_input((('%s [%s] ' % (self.prompt, default)) if (default is not None) else self.prompt))
        try:
            choice = int(choice)
        except ValueError:
            if (choice == ''):
                choice = default
            else:
                choice = None
        if ((not choice) or (choice > (len(self.choices) + 1)) or (choice < 1)):
            return (choice, INVALID_CHOICE)
        if (choice == (len(self.choices) + 1)):
            return (choice, QUIT_OPTION)
        result = self._handle_choice(choice)
        return result

    def _get_table_data(self):
        return self.choices

    def _handle_choice(self, choice):
        try:
            row_data = self.choices[(choice - 1)]
            return (choice, row_data)
        except KeyError:
            return (choice, INVALID_CHOICE)
        except IndexError:
            return (choice, INVALID_CHOICE)

    def _draw_table(self, table, has_heading):
        max_column_lengths = self._find_max_column_size(table)
        final_string = ''
        len_zeroes_rounded_up = math.ceil(math.log10(len(table)))
        max_padding = int((len_zeroes_rounded_up + len('1)  ')))
        row_counter = (0 if has_heading else 1)
        for row in table:
            if (row[0] == SPACER):
                row_string = ''
                row_counter -= 1
            elif ((row_counter == 0) and has_heading):
                row_string = (' ' * max_padding)
                row_string += (self._draw_row(row, max_column_lengths).rstrip() + '\n')
                row_string += self._draw_heading_dashes(max_column_lengths, max_padding)
            else:
                padding = ((max_padding - len(str(row_counter))) - len(')  '))
                row_string = (((' ' * padding) + str(row_counter)) + ')  ')
                row_string += self._draw_row(row, max_column_lengths)
            final_string += ('%s\n' % row_string.rstrip())
            row_counter += 1
        return final_string

    def _find_max_column_size(self, table):
        max_row_length = max([len(row) for row in table if row])
        max_column_lengths = ([0] * max_row_length)
        for row in table:
            if (row[0] == SPACER):
                break
            for row_item_index in range(len(row)):
                row_item = str(row[row_item_index])
                if (len(row_item) > max_column_lengths[row_item_index]):
                    max_column_lengths[row_item_index] = len(row_item)
        return max_column_lengths

    def _draw_heading_dashes(self, max_column_lengths, padding):
        dash_string = (' ' * padding)
        for column_index in range(len(max_column_lengths)):
            dash_string += ('-' * max_column_lengths[column_index])
            dash_string += '  '
        return dash_string

    def _draw_row(self, row, max_column_lengths):
        column_counter = 0
        row_string = ''
        for row_item in row:
            if hasattr(row_item, '__iter__'):
                row_string += row_item[0]
            else:
                row_string += row_item
            space_between = (' ' * ((max_column_lengths[column_counter] + 2) - len(row_item)))
            row_string += space_between
            column_counter += 1
        return row_string

class ListMenu(Menu, ):

    def __init__(self, heading, choices, choice_heading, prompt):
        Menu.__init__(self, heading, choices, choice_heading, prompt)
        if self.choice_heading:
            self.choice_heading = [choice_heading]

    def _get_table_data(self):
        settings = [[choice] for choice in self.choices]
        return settings

    def _find_max_column_size(self, table):
        max_length = 0
        for row in table:
            if (row[0] == SPACER):
                break
            row_item = row[0]
            if hasattr(row_item, '__iter__'):
                row_item = row_item[0]
            if (len(row_item) > max_length):
                max_length = len(row_item)
        return [max_length]

class FunctionMenu(ListMenu, ):

    def _handle_choice(self, choice):
        value = self.choices[(choice - 1)]
        if (len(value) == 2):
            function = value[1]
            function_result = function()
        else:
            function = value[1]
            function_result = function(*value[2:])
        return (choice, function_result)

class SettingsMenu(Menu, ):

    def __init__(self, heading, choices, prompt):
        Menu.__init__(self, heading, choices, ['Name', 'Current Value'], prompt)
        self.choices = self._map_choice_list(choices)

    def show(self):
        (choice, result) = Menu.show(self)
        while (result != QUIT_OPTION):
            (choice, result) = Menu.show(self)
        return dict(self.choices)

    def _map_choice_list(self, choices):
        if hasattr(choices, 'items'):
            choice_list = [[k, v] for (k, v) in choices.items()]
        else:
            choice_list = [[k, v] for (k, v) in choices]
        return choice_list

    def _handle_choice(self, choice):
        name = self.choices[(choice - 1)][0]
        new_value = raw_input(("Enter a new value for '%s' > " % name))
        self.choices[(choice - 1)][1] = new_value
        self.choices = self._map_choice_list(self.choices)
        return (self.choices, None)