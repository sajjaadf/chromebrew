require 'package'

class Cpsearch < Package
  description 'Chromebrew Package Search'
  homepage 'http://skycocker.github.io/chromebrew/'
  version '1.0'
  source_url 'file:///dev/null'
  source_sha256 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'

  depends_on 'gtkdialog'

  def self.build
    system "cat << 'EOF' > pkgsearch
#!/bin/bash
IFS=\$'\\n'
! test \$1 && exit 1
[[ \"\$1\" == \"-u\" ]] && rm -f /tmp/allpkgs.txt && exit 0
[ ! -f /tmp/allpkgs.txt ] && crew search > /tmp/allpkgs.txt
grep -i \"\$1\" /tmp/allpkgs.txt > /tmp/pkgs.txt
if [ -s /tmp/pkgs.txt ]; then
  cat /tmp/pkgs.txt | cut -d':' -f1 > /tmp/pkgnames.txt
  if [ -s /tmp/pkgnames.txt ]; then
    clear && cat /tmp/pkgnames.txt
  fi
fi
EOF"
system "cat << 'EOF' > cpsearch
#!/bin/bash
export MAIN_DIALOG='
<window title=\"Package Search\" width-request=\"280\" height-request=\"100\">
<vbox homogeneous=\"true\">
  <hbox space-fill=\"true\">
    <text><label>Keyword(s):</label></text>
    <entry activates_default=\"true\"><variable>KEYWORD</variable></entry>
  </hbox>
  <hseparator width-request=\"270\"></hseparator>
  <hbox homogeneous=\"true\">
    <button use-underline=\"true\" can-default=\"true\" has-default=\"true\">
      <label>_Search</label>
      <action>pkgsearch $KEYWORD</action>
    </button>
    <button use-underline=\"true\">
      <label>_Update</label>
      <action>pkgsearch -n</action>
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
    system "install -Dm755 pkgsearch #{CREW_DEST_PREFIX}/bin/pkgsearch"
    system "install -Dm755 cpsearch #{CREW_DEST_PREFIX}/bin/cpsearch"
  end
end
