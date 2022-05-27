#!/usr/bin/python3

#sudo apt install gir1.2-appindicator3-0.1
#sudo apt install smartmontools
#sudo chmod u+s /usr/sbin/smartctl
#pip3 install psutil

import os
import signal
import gi
import re
import time
import threading
import subprocess
import shutil
import psutil
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk, AppIndicator3, GObject

import conf


def format_bytes(size):
    power = 2**10 # = 1024
    n = 0
    power_labels = {0 : '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while size > power:
        size /= power
        n += 1
    return str(int(size)) + ' ' + power_labels[n]

def format_temp(temp):
    return str(int(temp)) + '°C'

currpath = os.path.dirname(os.path.realpath(__file__))


class Indicator():
    def __init__(self):
        self.app = 'sysmon'
        iconpath = currpath+'/icon.svg'
        self.temperature = '?'
        self.indicator = AppIndicator3.Indicator.new(
            self.app, iconpath,
            AppIndicator3.IndicatorCategory.OTHER)
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.create_menu())
        self.do = True
        threading.Thread(target=self.run).start()

    def create_menu(self):
        menu = Gtk.Menu()
        item_quit = Gtk.MenuItem(label='Quit')
        item_quit.connect('activate', self.stop)
        menu.append(item_quit)
        menu.show_all()
        return menu

    def stop(self, source):
        self.do = False
        Gtk.main_quit()

    def updaet_temp(self):
        self.cpu_temp = '?°C'
        self.drive_temp = '?°C'
        temps = psutil.sensors_temperatures()
        for name, entries in temps.items():
            if name == 'coretemp':
                for entry in entries:
                    if entry.label == 'Package id 0':
                        self.cpu_temp = format_temp(entry.current)
            if name == 'nvme':
                for entry in entries:
                    self.drive_temp = format_temp(entry.current)

    def cpu_use(self):
        return str(int(psutil.cpu_percent())) + '%'

    def ram_use(self):
        return format_bytes(psutil.virtual_memory().total - psutil.virtual_memory().available)

    def make_label(self):
        self.updaet_temp()
        label = ' ' + self.cpu_temp + ' ' + self.cpu_use() + ' ' + self.ram_use() + ' | ' + self.drive_temp
        for vol in conf.volumes:
            if os.path.exists(vol):
                total, used, free = shutil.disk_usage(vol)
                label += ' ' + format_bytes(free) + '/' + str(int(used / total * 100)) + '%'
        return label

    def run(self):
        step = 10
        n = step
        while self.do:
            if n == step:
                n = 0
                self.indicator.set_label(self.make_label(), '')
            n = n + 1
            time.sleep(0.1)


Indicator()
signal.signal(signal.SIGINT, signal.SIG_DFL)
Gtk.main()
