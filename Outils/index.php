<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title>BAO - Supervision</title>
            <meta http-equiv="refresh" content="300">
            <style type="text/css">
                .container {
                    display: grid;
                    grid-template-columns: 1fr 1fr 1fr; /* fraction*/
                }
            </style>
		</head>
		<body>
			<?php
                date_default_timezone_set('Europe/Paris');
                $dirname = "./";
                $images = glob($dirname."*.png");
                $i = 0;

                $nbimage = count($images);

                If ($nbimage == 0) {
                    echo '<p>Aucune capture disponible</p>'."\n";
                } else {

                    if ($nbimage < 3) {
                        echo '<div>'."\n";
                    }

                    foreach($images as $image) {
                        $i += 1;

                        If ($nbimage > 2 && $i == 1) {
                            echo '<div class="container">'."\n";
                        }

                        $timeimage = filemtime($image);
                        $style = " border: 2px solid";
                        If (time() > ($timeimage + 905)) {
                            $style .= " red;";
                        } else {
                            $style .= " green;";
                        }
                        echo '<a href="'.$image.'"  title="'.$image.' '.date ("d-m-y H:i", $timeimage).'" style="margin: 3px;"><img src="'.$image.'" style="width:100%;'.$style.'" /></a>'."\n";
                        If ($i == 3) {
                            echo '</div>'."\n";
                            $i = 0;
                        }
                    }
                    if ($i <> 0) {
                        echo '</div>'."\n";
                    }
                }
            ?>
		</body>
	</html>