require 'package'

class Cpsearch < Package
  description 'Chromebrew Package Search'
  homepage 'http://skycocker.github.io/chromebrew/'
  version '1.0'
  source_url 'file:///dev/null'
  source_sha256 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'

  depends_on 'gtkdialog'

  def self.build
    system "cat << 'EOF' > cpsearch
#!/bin/bash
IFS=\$'\\n'
pkgsearch () {
  [ -f /tmp/packages.txt ] || crew search > /tmp/allpkgs.txt
  grep -i \"\$KEYWORD\" /tmp/allpkgs.txt > /tmp/pkgs.txt
  [ -s /tmp/pkgs.txt ] && cat /tmp/pkgs.txt
}
export -f pkgsearch
export MAIN_DIALOG='
<window title=\"Chromebrew Package Search\" width-request=\"250\" height-request=\"90\">
<vbox homogeneous=\"true\">
  <hbox space-fill=\"true\">
    <text><label>Keyword: </label></text>
    <entry activates_default=\"true\"><variable>KEYWORD</variable></entry>
  </hbox>
  <hseparator width-request=\"240\"></hseparator>
  <hbox homogeneous=\"true\">
    <button use-underline=\"true\" can-default=\"true\" has-default=\"true\">
      <label>_Search</label>
      <action>pkgsearch</action>
    </button>
    <button cancel></button>
  </hbox>
</vbox>
</window>
'
gtkdialog -p MAIN_DIALOG --center
EOF"
  end

  def self.install
    system "install -Dm755 cpsearch #{CREW_DEST_PREFIX}/bin/cpsearch"
  end
end
