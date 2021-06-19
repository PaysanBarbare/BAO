Local $source = BinaryToString(InetRead("https://www.nirsoft.net/utils/web_browser_password.html"), 4)
	local $array = StringRegExp($source, "copyTextToClipboard\(\'(.*?)\'\);", 1)

			MsgBox(0,"", $array[0])
