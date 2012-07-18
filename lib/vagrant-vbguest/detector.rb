module VagrantVbguest
  class Detector

    def initialize(vm, options)
      @vm = vm
      @options = options
    end

    def iso_path
      @iso_path ||= autodetect_iso
    end

    private

      def autodetect_iso
        path = media_manager_iso || guess_iso || (!@options[:no_remote] && web_iso)
        raise VagrantVbguest::Errors::IsoPathAutodetectionError if !path || path.empty?
        path
      end

      def media_manager_iso
        (m = @vm.driver.execute('list', 'dvds').match(/^.+:\s+(.*VBoxGuestAdditions.iso)$/i)) && m[1]
      end

      def guess_iso
        path_platform = if Vagrant::Util::Platform.linux?
          "/usr/share/virtualbox/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.darwin?
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.windows?
          if (p = ENV["VBOX_INSTALL_PATH"]) && !p.empty?
            File.join(p, "VBoxGuestAdditions.iso")
          else
            File.join((ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]), "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
          end
        end
        File.exists?(path_platform) ? path_platform : nil
      end

      def web_iso
        "http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso"
      end

  end
end