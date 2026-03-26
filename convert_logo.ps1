# Script para converter logo.jpeg em PNG para Android e iOS
Add-Type -AssemblyName System.Drawing

# Definir paths
$logoPath = "C:\Users\kkevi\Desktop\Derma-SDAC---Detec-o-de-Melanomas\assets\logo.jpeg"
$androidPath = "C:\Users\kkevi\Desktop\Derma-SDAC---Detec-o-de-Melanomas\android\app\src\main\res"
$iosPath = "C:\Users\kkevi\Desktop\Derma-SDAC---Detec-o-de-Melanomas\ios\Runner\Assets.xcassets\AppIcon.appiconset"

# Carregar imagem original
$originalImage = [System.Drawing.Image]::FromFile($logoPath)

# Tamanhos iOS
$iosSizes = @(
    @{size=1024; suffix="1024x1024@1x"},
    @{size=180; suffix="60x60@3x"},
    @{size=120; suffix="60x60@2x"},
    @{size=167; suffix="83.5x83.5@2x"},
    @{size=152; suffix="76x76@2x"},
    @{size=76; suffix="76x76@1x"},
    @{size=120; suffix="40x40@3x"},
    @{size=80; suffix="40x40@2x"},
    @{size=40; suffix="40x40@1x"},
    @{size=87; suffix="29x29@3x"},
    @{size=58; suffix="29x29@2x"},
    @{size=29; suffix="29x29@1x"},
    @{size=60; suffix="20x20@3x"},
    @{size=40; suffix="20x20@2x"},
    @{size=20; suffix="20x20@1x"}
)

# Tamanhos Android (mipmap)
$androidSizes = @(
    @{folder="mipmap-mdpi"; size=48},
    @{folder="mipmap-hdpi"; size=72},
    @{folder="mipmap-xhdpi"; size=96},
    @{folder="mipmap-xxhdpi"; size=144},
    @{folder="mipmap-xxxhdpi"; size=192}
)

# Função para redimensionar imagem
function Resize-Image {
    param(
        [System.Drawing.Image]$image,
        [int]$width,
        [int]$height,
        [string]$outputPath
    )
    
    $resized = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.DrawImage($image, 0, 0, $width, $height)
    $graphics.Dispose()
    
    $resized.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $resized.Dispose()
    Write-Host "Criado: $outputPath"
}

# Converter para Android
Write-Host "Convertendo para Android..."
foreach ($android in $androidSizes) {
    $outputPath = "$androidPath\$($android.folder)\ic_launcher.png"
    Resize-Image -image $originalImage -width $android.size -height $android.size -outputPath $outputPath
}

# Converter para iOS
Write-Host "Convertendo para iOS..."
foreach ($ios in $iosSizes) {
    $output = "$iosPath\Icon-App-$($ios.suffix).png"
    Resize-Image -image $originalImage -width $ios.size -height $ios.size -outputPath $output
}

$originalImage.Dispose()
Write-Host "Conversão concluída!"
