$dataDir = ".\resources\persistance\"
If(!(test-path $dataDir))
{
    (New-Item -ItemType Directory -Force -Path $dataDir) | Out-Null
}

function save ($var, $value) {
	$var="$dataDir$var.var"
	Set-Content -Path $var -Value $value
}

function load ($var) {
	$var="$dataDir$var.var"
	if(test-path $var) {
		return (Get-Content -Path $var)
	}
}
