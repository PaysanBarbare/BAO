<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title>BAO - Supervision</title>
            <meta http-equiv="refresh" content="300">
		</head>
		<body>
			<?php
                date_default_timezone_set('Europe/Paris');
                $dirname = "./";
                $images = glob($dirname."*.png");
                $i = 0;

                $nbimage = count($images);
                $width = "33%";

                If ($nbimage == 0) {
                    echo '<p>Aucune capture disponible</p>';
                }
                else {

                    If ($nbimage == 1) {
                        $width = "100%";
                    }
                    elseif ($nbimage == 2) {
                        $width = "50%";
                    }
                    foreach($images as $image) {
                        $i += 1;
                        $timeimage = filemtime($image);
                        $style = " border: 1px solid";
                        If (time() > ($timeimage + 905)) {
                            $style .= " red;";
                        } else {
                            $style .= " green;";
                        }
                        echo '<a href="'.$image.'" title="'.$image.' '.date ("d-m-y H:i", $timeimage).'" style="float: left; margin: 2px; width: '.$width.';'.$style.'"><img src="'.$image.'" style="width:100%;" /></a>';
                        If ($i == 3) {
                            echo '<br />';
                            $i = 0;
                        }
                    }
                }
            ?>
		</body>
	</html>