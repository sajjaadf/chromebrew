require 'package'

class Cpsearch < Package
  description 'Chromebrew Package Search'
  homepage 'https://skycocker.github.io/chromebrew/'
  version '1.0'
  source_url 'file:///dev/null'
  source_sha256 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'

  depends_on 'gtkdialog'

  def self.build
    system "cat << 'EOF' > pkgsearch
#!/bin/bash
TMP=#{CREW_PREFIX}/tmp
ALL=\$TMP/all.txt
PKGS=\$TMP/pkgs.txt
NAMES=\$TMP/names.txt
CBS=\$TMP/checkboxes.txt
IFS=\$'\\n'
! test \$1 && exit 1
[[ \"\$1\" = \"-u\" ]] && rm -f \$ALL && exit 0
[ ! -f \$ALL ] && crew search \> \$ALL
grep -i \"\$1\" \$ALL \> \$PKGS
# remove special character color codes
sed -i \"s,\\x1B\\[[0-9;]*[a-zA-Z],,g\" \$PKGS
if [ -s \$PKGS ]; then
  cat \$PKGS | cut -d':' -f1 \> \$NAMES
  if [ -s \$NAMES ]; then
    rm -f \$CBS
    for p in \$(cat \$NAMES); do
      i=\$(echo \$p | cut -d' ' -f1)
      [[ \"\$i\" = \"(i)\" ]] && p=\$(echo \$p | cut -d' ' -f2)
      echo false \> \$TMP/\$p
      [[ \"\$i\" = \"(i)\" ]] && echo true \> \$TMP/\$p
      echo \"<checkbox>
  <label>\$p</label>
  <variable>\$p</variable>
  <input>cat \$TMP/\$p</input>
  <action>refresh:\$p</action>
</checkbox>\" \>\> \$CBS
    done
  fi
fi
EOF"
system "cat << 'EOF' > cpsearch
#!/bin/bash
TMP=#{CREW_PREFIX}/tmp
CBS=\$TMP/checkboxes.txt
HEIGHT=100
[ -s \$CBS ] && HEIGHT=\$((\$HEIGHT + \$(wc -l \$CBS | cut -d' ' -f1)))
export main_dialog='
<window title=\"Package Search\" width-request=\"280\" height-request=\"\${HEIGHT}\">
<vbox homogeneous=\"true\">
  <hbox space-fill=\"true\">
    <text><label>Keyword(s):</label></text>
    <entry activates_default=\"true\"><variable>KEYWORD</variable></entry>
  </hbox>'
  [ -s \$CBS ] \&\& main_dialog=\${main_dialog}\$(cat \$CBS)
  main_dialog=\${main_dialog}'
  <hseparator width-request=\"270\"></hseparator>
  <hbox homogeneous=\"true\">
    <button use-underline=\"true\" can-default=\"true\" has-default=\"true\">
      <label>_Search</label>
      <action>pkgsearch \$KEYWORD</action>
    </button>
    <button use-underline=\"true\">
      <label>_Update</label>
      <action>pkgsearch -u</action>
    </button>
    <button cancel></button>
  </hbox>
</vbox>
</window>
'
export MAIN_DIALOG=\"\${main_dialog}\"
gtkdialog -p MAIN_DIALOG --center
EOF"
  end

  def self.install
    system "install -Dm755 pkgsearch #{CREW_DEST_PREFIX}/bin/pkgsearch"
    system "install -Dm755 cpsearch #{CREW_DEST_PREFIX}/bin/cpsearch"
  end
end
