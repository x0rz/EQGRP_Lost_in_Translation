# -*- coding: utf-8 -*-
import os,sys,time
import pyreadline.logger as logger
from   pyreadline.logger import log,log_sock
from pyreadline.lineeditor.lineobj import Point
import pyreadline.lineeditor.lineobj as lineobj
import pyreadline.lineeditor.history as history
import emacs 
import string

class FuzzbunchMode(emacs.EmacsMode):
    mode="fuzzbunch"
    def __init__(self,rlobj):
        super(FuzzbunchMode,self).__init__(rlobj)
        self._keylog=(lambda x,y: None)
        self.previous_func=None
        self.prompt=">>>"
    def __repr__(self):
        return "<FuzzbunchMode>"

    def _get_completions(self):
        '''Return a list of possible completions for the string ending at the point.

        Also set begidx and endidx in the process.'''
        completions = []
        self.begidx = self.l_buffer.point
        self.endidx = self.l_buffer.point
        buf=self.l_buffer.line_buffer
        if self.completer:
            # get the string to complete
            while self.begidx > 0:
                self.begidx -= 1
                if buf[self.begidx] in self.completer_delims:
                    self.begidx += 1
                    break
            text = ''.join(buf[self.begidx:self.endidx])
            log('complete text="%s"' % text)
            i = 0
            while 1:
                try:
                    r = self.completer(text, i)
                except:
                    break
                i += 1
                if r and r not in completions:
                    completions.append(r)
                else:
                    break
            if len(completions) == 1:
                completions[0] = completions[0] + " "
            log('text completions=%s' % completions)
        return completions


