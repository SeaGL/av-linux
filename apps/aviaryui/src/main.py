# main.py
#
# Copyright 2025 AJ Jordan
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: AGPL-3.0-or-later

import sys
import json
# XXX figure out how the fuck to install requests from PyPI so we can use it instead of stdlib
from urllib import request

import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Gio, Adw, GLib, Soup
from .window import AviaryuiWindow


class AviaryuiApplication(Adw.Application):
    """The main application singleton class."""

    def __init__(self):
        super().__init__(application_id='org.seagl.AviaryUI',
                         flags=Gio.ApplicationFlags.DEFAULT_FLAGS,
                         resource_base_path='/org/seagl/AviaryUI')
        self.create_action('quit', lambda *_: self.quit(), ['<primary>q'])
        self.create_action('about', self.on_about_action)
        #self.create_action('toggle-livestream', self.on_toggle_livestream_action)

        toggle_action = Gio.SimpleAction.new_stateful('toggle-livestream', None, GLib.Variant.new_boolean(False))
        toggle_action.connect("activate", self.on_toggle_livestream_action)
        self.add_action(toggle_action)

        #toggle_action = Gio.PropertyAction.new('toggle-livestream', self.props.active_window.stream_toggle, '')
        #toggle_action.connect(self.on_toggle_livestream_action)
        #self.add_action(toggle_action)

    def do_activate(self):
        """Called when the application is activated.

        We raise the application's main window, creating it if
        necessary.
        """
        win = self.props.active_window
        if not win:
            win = AviaryuiWindow(application=self)
        self.synchronize_ui()
        win.present()

    def on_about_action(self, *args):
        """Callback for the app.about action."""
        about = Adw.AboutDialog(application_name='SeaGL Stream Control',
                                application_icon='org.seagl.AviaryUI',
                                developer_name='AJ Jordan',
                                version='0.1.0',
                                developers=['AJ Jordan'],
                                copyright='© 2025 AJ Jordan')
        # Translators: Replace "translator-credits" with your name/username, and optionally an email or URL.
        about.set_translator_credits(_('translator-credits'))
        about.present(self.props.active_window)

    def get_config(self):
        # TODO reload this on changes, somehow
        try:
            with open('/var/lib/seagl/config-data.json', encoding='utf-8') as f:
                config_data = json.loads(f.read())['aviaryui']
        except FileNotFoundError:
            # TODO do some kind of double-check that we are in dev
            raw = Gio.resources_lookup_data('/org/seagl/AviaryUI/config.dev.json', Gio.ResourceLookupFlags.NONE).get_data()
            config_data = json.loads(str(raw, 'utf-8'))['aviaryui']
        return config_data

    def synchronize_ui(self):
        """
        Synchronize the UI with application state.

        This function is idempotent and should be called whenever application state changes, or may have changed.
        """
        currently_streaming = self.lookup_action('toggle-livestream').get_state()
        status_label = self.props.active_window.status_label
        # XXX just rename this
        toggle_button = self.props.active_window.stream_toggle

        if currently_streaming:
            status_label.set_label('The livestream is 🟢 online.')
            toggle_button.set_label('Stop room broadcast')
            toggle_button.set_css_classes(['destructive-action'])
        else:
            # TODO find a way to make this clarification accessible
            #status_label.set_label('The livestream is ❌ offline (showing the schedule, not the room feed).')
            status_label.set_label('The livestream is ❌ offline.')
            toggle_button.set_label('Start room broadcast')
            toggle_button.set_css_classes(['suggested-action'])

        announcement_label = self.props.active_window.announcement_label
        config_data = self.get_config()
        announcement_label.set_label(config_data['contact_instructions'])

    def on_toggle_livestream_action(self, *args):
        """Callback to toggle the room stream on and off."""
        action = args[0]
        # TODO figure out how to just bind this to a toggle
        # And not do this stupid shit
        new_state = not action.get_state()
        action.change_state(GLib.Variant.new_boolean(new_state))

        status_label = self.props.active_window.status_label
        status_label.set_label('⚠️ Transitioning - this will take 15 seconds...')
        toggle_button = self.props.active_window.stream_toggle
        toggle_button.set_sensitive(False)

        session = Soup.Session()
        # TODO use a real POST request
        message = Soup.Message.new('GET', f'http://localhost:9000/aviaryui/set-livestream-state?state={new_state}')

        def on_response(session, result, _):
            # TODO handle exceptions
            response = session.send_and_read_finish(result)
            toggle_button.set_sensitive(True)
            self.synchronize_ui()
            #data = response.get_data().decode()
            #print(data)

        session.send_and_read_async(message, GLib.PRIORITY_DEFAULT, None, on_response, None)

    def create_action(self, name, callback, shortcuts=None):
        """Add an application action.

        Args:
            name: the name of the action
            callback: the function to be called when the action is
              activated
            shortcuts: an optional list of accelerators
        """
        action = Gio.SimpleAction.new(name, None)
        action.connect("activate", callback)
        self.add_action(action)
        if shortcuts:
            self.set_accels_for_action(f"app.{name}", shortcuts)


def main(version):
    """The application's entry point."""
    app = AviaryuiApplication()
    return app.run(sys.argv)
