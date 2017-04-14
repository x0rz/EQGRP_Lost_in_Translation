
from __future__ import print_function
import math
import numbers
import platform
if (platform.python_version_tuple()[0] == '3'):
    raw_input = input
__all__ = ['Menu']
_dsz_mode = False
try:
    import dsz
    import dsz.ui

    def utf8(s):
        return (s.encode('utf8') if (type(s) is unicode) else str(s))
    _dsz_mode = True
except ImportError:
    pass
_util_ip_mode = False
try:
    import ip
    _util_ip_mode = True
except ImportError:
    pass
EXIT = 'Exit'

def _functiontype():
    pass

class Menu(object, ):

    def __init__(self):
        self.__section_order = ['']
        self.__section_content = {'': []}
        self.__heading = None
        self.__current = None
        self.__current_index = None
        self.__current_section = None
        self.__display = None
        self.__output = None
        self.__needs_update = True

    @property
    def sections(self):
        return self.__section_order

    @property
    def current(self):
        assert (self.__current is not None), 'This method can only be invoked from within a callback.'
        return self.__current

    @property
    def current_section(self):
        assert (self.__current_section is not None), 'This method can only be invoked from within a callback.'
        return self.__current_section

    def set_current_text(self, text):
        assert (self.__current_index is not None), 'This method can only be invoked from within a callback.'
        assert ((type(text) is str) or (type(text) is unicode)), 'text must be str or unicode'
        self.__section_content[self.__current_section][self.__current_index]['text'] = text
        self.__needs_update = True

    def set_current_state(self, state):
        assert (self.__current_index is not None), 'This method can only be invoked from within a callback.'
        self.__section_content[self.__current_section][self.__current_index]['state'] = state
        self.__needs_update = True

    def set_current_callback(self, callback):
        assert (self.__current_index is not None), 'This method can only be invoked from within a callback.'
        assert callable(callback), 'callback must be a function'
        self.__section_content[self.__current_section][self.__current_index]['callback'] = callback

    def set_current_cbparam(self, **optdict):
        assert (self.__current_index is not None), 'This method can only be invoked from within a callback.'
        self.__section_content[self.__current_section][self._current_index]['cbparam'] = optdict

    def set_current_keywords(self, keywords):
        assert (self.__current_index is not None), 'This method can only be invoked from within a callback.'
        assert (type(keywords) is list), 'keywords must be a list'
        self.__section_content[self.__current_index]['keywords'] = keywords
        self.__needs_update = True

    def add_section(self, section):
        assert ((type(section) is str) or (type(section) is unicode)), 'str or unicode string required'
        if (section not in self.__section_order):
            self.__section_order.append(section)
            self.__section_content[section] = []
            self.__needs_update = True
            return True
        else:
            return False

    def add_option(self, option, section='', keywords=[], callback=None, state=None, hex=False, **optdict):
        assert ((type(section) is str) or (type(section) is unicode)), 'str or unicode string required'
        assert ((type(option) is str) or (type(option) is unicode)), 'str or unicode string required'
        assert ((callback is None) or (type(callback) is type(_functiontype)) or (type(callback) is type(self.add_option))), 'callback must be a function, instancemethod, or None'
        self.add_section(section)
        self.__section_content[section].append({'text': option, 'keywords': keywords, 'callback': callback, 'cbparam': optdict, 'state': state, 'hex': hex})
        self.__needs_update = True

    def callback_str(self, allowempty=False, default=None):
        result = None
        while True:
            result = self.__raw_input(('New value for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default))
            if (result or ((result == '') and allowempty)):
                break
        self.set_current_state(result)

    def add_str_option(self, option, state, section='', keywords=[], allowempty=False, default=None):
        self.add_option(option=option, section=section, state=state, keywords=keywords, callback=self.callback_str, allowempty=allowempty, default=default)

    def callback_int(self, default=None):
        self.set_current_state(self.__int_input(('New value for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default)))

    def add_int_option(self, option, state, section='', keywords=[], default=None):
        assert isinstance(state, numbers.Integral), 'State must be an integer.'
        self.add_option(option=option, section=section, state=state, keywords=keywords, callback=self.callback_int, default=default)

    def callback_hex(self, default=None):
        defresponse = (hex(self.current['state']) if (default is None) else default)
        if (defresponse[(-1)] == 'L'):
            defresponse = defresponse[0:(-1)]
        self.set_current_state(self.__int_input(('New value for "%s":' % self.current['text']), defresponse))

    def add_hex_option(self, option, state, section='', keywords=[], default=None):
        assert isinstance(state, numbers.Integral), 'State must be an integer.'
        self.add_option(option=option, state=state, section=section, keywords=keywords, callback=self.callback_hex, default=default, hex=True)

    def callback_toggle(self, enabled='Enabled', disabled='<DISABLED>'):
        if (self.current['state'] == enabled):
            self.set_current_state(disabled)
        else:
            self.set_current_state(enabled)

    def add_toggle_option(self, option, state=None, section='', keywords=[], enabled='Enabled', disabled='<DISABLED>'):
        assert ((state is None) or (state == enabled) or (state == disabled)), 'Starting state must be either enabled or disabled.'
        self.add_option(option=option, state=(state if (state is not None) else disabled), section=section, keywords=keywords, callback=self.callback_toggle, enabled=enabled, disabled=disabled)

    def set_heading(self, heading):
        assert ((type(heading) is list) or (type(heading) is str) or (type(heading) is unicode)), 'Heading content must be list, str, or unicode'
        if ((type(heading) is str) or (type(heading) is unicode)):
            self.__heading = [heading]
        else:
            self.__heading = heading
        self.__needs_update = True

    def execute(self, prompt='Enter selection', default=None, keywords=[], menuloop=True, exit=EXIT, exiton=[]):
        assert ((type(prompt) is str) or (type(prompt) is unicode)), 'Prompt must be str or unicode'
        assert (type(menuloop) is bool), 'Must be a Boolean state.'
        assert ((type(exit) is str) or (type(exit) is unicode)), 'str or unicode required'
        assert ((default is None) or (type(default) is int)), 'Use None for no default or enter a valid integer.'
        assert (type(exiton) is list), 'exiton must be a list'
        self.build_menu(keywords, exit)
        maxvalue = (len(self.__display) - 1)
        if (type(default) is int):
            assert ((default >= 0) and (default <= maxvalue)), 'Default value must be within range of options.'
        if menuloop:
            result = (-1)
            exiton.append(0)
            while (result not in exiton):
                if _dsz_mode:
                    dsz.script.CheckStop()
                self.display(keywords, exit)
                result = self.__menu_input(prompt, default, maxvalue)
                if result:
                    self.__callback(self.__display[result][0], self.__display[result][2])
        else:
            self.display(keywords, exit)
            result = self.__menu_input(prompt, default, maxvalue)
            if result:
                self.__callback(self.__display[result][0], self.__display[result][2])
        exit_state = {'selection': result, 'option': (self.__display[result][1]['text'] if (result != 0) else exit), 'option_state': (self.__display[result][1]['state'] if (result != 0) else None), 'all_states': self.all_states()}
        return exit_state

    def all_states(self):
        all = {}
        for s in self.__section_order:
            all[s] = {}
            for i in self.__section_content[s]:
                if i['state']:
                    all[s][i['text']] = i['state']
            if (not all[s]):
                del all[s]
        return all

    def display(self, keywords=[], exit=EXIT):
        print(self.build_menu(keywords, exit))

    def build_menu(self, keywords=[], exit=EXIT):
        assert (type(keywords) is list)
        assert ((type(exit) is str) or (type(exit) is unicode))
        if (not self.__needs_update):
            return self.__output
        self.__output = '\n'
        if self.__heading:
            for i in self.__heading:
                self.__output += (i + '\n')
            self.__output += '\n'
        lpad = str((int(math.log10((sum([len(i) for i in self.__section_content]) | 1))) + 3))
        self.__output += ((('%' + lpad) + 'd) %s\n') % (0, exit))
        self.__display = [None]
        for s in self.__section_order:
            if (s == ''):
                self.__output += '\n'
            else:
                self.__output += ('\n %s\n' % s)
            longest = 0
            for i in self.__section_content[s]:
                if i['state']:
                    if (len(i['text']) > longest):
                        longest = len(i['text'])
            index = 0
            for i in self.__section_content[s]:
                if ((not keywords) or (not i['keywords']) or (True in [(k in keywords) for k in i['keywords']])):
                    self.__output += ((('%' + lpad) + 'd) %s') % (len(self.__display), i['text']))
                    self.__display.append([s, i, index])
                    if i['state']:
                        self.__output += (' ' * (longest - len(i['text'])))
                        if i['hex']:
                            hexed = hex(i['state'])
                            if (hexed[(-1)] == 'L'):
                                hexed = hexed[0:(-1)]
                            self.__output += (': %s' % hexed)
                        else:
                            self.__output += (': %s' % i['state'])
                    self.__output += '\n'
                index += 1
        self.__needs_update = False
        return self.__output

    def __callback(self, section, index):
        content = self.__section_content[section][index]
        if (content['callback'] is not None):
            self.__current = content
            self.__current_index = index
            self.__current_section = section
            if (content['cbparam'] is None):
                content['callback']()
            else:
                content['callback'](**content['cbparam'])
            self.__current = None
            self.__current_index = None
            self.__current_section = None

    def __menu_input(self, prompt, default, maxvalue):
        result = (-1)
        while ((result < 0) or (result > maxvalue)):
            result = self.__int_input(prompt, default)
        return result

    def __raw_input(self, prompt, default):
        newprompt = (prompt if (prompt and (prompt[(-1)] in [':', '?'])) else (prompt + ':'))
        if _dsz_mode:
            return dsz.ui.GetString(utf8(newprompt), ('' if (default is None) else utf8(default)))
        else:
            value = raw_input(((newprompt + (' [%s] ' % default)) if (default is not None) else newprompt))
            if ((value == '') and (default is not None)):
                return default
            return value

    def __int_input(self, prompt, default):
        if _dsz_mode:
            newprompt = (prompt if (prompt and (prompt[(-1)] in [':', '?'])) else (prompt + ':'))
            return dsz.ui.GetInt(utf8(newprompt), ('' if (default is None) else str(default)))
        else:
            while True:
                value = self.__raw_input(prompt, default)
                if (type(value) is int):
                    return value
                try:
                    if ((len(value) > 2) and (value[0:2].lower() == '0x')):
                        return int(value, 16)
                    else:
                        return int(value)
                except ValueError:
                    pass
    if _util_ip_mode:

        def callback_ip(self, default=None):
            valid = False
            result = None
            while (not valid):
                result = self.__raw_input(('New IP address for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default))
                valid = util.ip.validate(result)
                if (not valid):
                    if _dsz_mode:
                        dsz.ui.Echo('Invalid IP address.', dsz.ERROR)
                    else:
                        print('Invalid IPv4 or IPv6 address.')
            self.set_current_state(result)

        def add_ip_option(self, option, section='', keywords=[], ip=None, default=None):
            assert ((ip is None) or util.ip.validate(ip)), 'ip must be a valid IPv4 or IPv6 address, or None'
            self.add_option(option=option, section=section, state=ip, keywords=keywords, callback=self.callback_ip, default=default)

        def callback_ipv4(self, default=None):
            valid = False
            result = None
            while (not valid):
                result = self.__raw_input(('New IPv4 address for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default))
                valid = util.ip.validate_ipv4(result)
                if (not valid):
                    if _dsz_mode:
                        dsz.ui.Echo('Invalid IPv4 address.', dsz.ERROR)
                    else:
                        print('Invalid IP address.')
            self.set_current_state(result)

        def add_ipv4_option(self, option, section='', keywords=[], ip=None, default=None):
            assert ((ip is None) or util.ip.validate_ipv4(ip)), 'ip must be a valid IPv4, or None'
            self.add_option(option=option, section=section, state=(ip if ip else '127.0.0.1'), keywords=keywords, callback=self.callback_ipv4, default=default)

        def callback_ipv6(self, default=None):
            valid = False
            result = None
            while (not valid):
                result = self.__raw_input(('New IPv6 address for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default))
                valid = util.ip.validate_ipv6(result)
                if (not valid):
                    if _dsz_mode:
                        dsz.ui.Echo('Invalid IPv6 address.', dsz.ERROR)
                    else:
                        print('Invalid IP address.')
            self.set_current_state(result)

        def add_ipv6_option(self, option, section='', keywords=[], ip=None, default=None):
            assert ((ip is None) or util.ip.validate_ipv6(ip)), 'ip must be a valid IPv6, or None'
            self.add_option(option=option, section=section, state=(ip if ip else '::1'), keywords=keywords, callback=self.callback_ipv6, default=default)

        def callback_frz(self, default=None):
            valid = False
            result = None
            while (not valid):
                result = self.__raw_input(('New FRZ address for "%s"' % self.current['text']), (self.current['state'] if (default is None) else default))
                valid = (result and (result[0] == 'z') and util.ip.validate_ipv4(result[1:]))
                if (not valid):
                    if _dsz_mode:
                        dsz.ui.Echo('Invalid IPv4 address.', dsz.ERROR)
                    else:
                        print('Invalid FRZ address.')
            self.set_current_state(result)

        def add_frz_option(self, option, section='', keywords=[], frz=None, default=None):
            assert ((frz is None) or ((frz[0] == 'z') and util.ip.validate_ipv4(frz[1:]))), 'frz must be a valid FRZ address, or None'
            self.add_option(option=option, section=section, state=(frz if frz else 'z0.0.0.1'), keywords=keywords, callback=self.callback_frz, default=default)
if (__name__ == '__main__'):
    test = Menu()
    test.add_option('Exit and do stuff')
    test.add_str_option('Log', section='Configuration', state='C:\\Windows\\Temp\\log.log')
    test.add_hex_option('ID', section='Configuration', state=268444485)
    test.add_hex_option('ID', section='Configuration', state=17592454488901L)
    test.add_int_option('Loops', section='Advanced', state=((((((((3 * 3) * 3) * 3) * 3) * 3) * 3) * 3) * 3))
    if _util_ip_mode:
        test.add_ip_option('IP', section='Configuration', ip='1.2.3.4')
        test.add_ipv4_option('IPv4', section='Configuration', ip='9.6.3.0')
        test.add_ipv6_option('IPv6', section='Configuration', ip='1234:abcd::5%9')
        test.add_frz_option('FRZ', section='ADVANCED', frz='z7.7.7.7')
    print(test.execute(exiton=[1], default=1))