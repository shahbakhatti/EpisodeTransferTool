Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "TV Show Episode Copier"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

# Global variables
$sourcePath = ""
$destPath = ""
$episodeCount = 5

# Labels
$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Location = New-Object System.Drawing.Point(20, 200)
$labelStatus.Size = New-Object System.Drawing.Size(350, 40)
$labelStatus.Text = "Status: Waiting..."
$form.Controls.Add($labelStatus)

# Browse Source Button
$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse Show Folder"
$btnSource.Location = New-Object System.Drawing.Point(20, 20)
$btnSource.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $sourcePath = $dialog.SelectedPath
        $labelStatus.Text = "Selected Show Folder: $sourcePath"
    }
})
$form.Controls.Add($btnSource)

# Browse Destination Button
$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse Flash Drive"
$btnDest.Location = New-Object System.Drawing.Point(20, 60)
$btnDest.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $destPath = $dialog.SelectedPath
        $labelStatus.Text = "Selected Flash Drive: $destPath"
    }
})
$form.Controls.Add($btnDest)

# Episode Count Label
$labelCount = New-Object System.Windows.Forms.Label
$labelCount.Text = "Episodes to Copy: $episodeCount"
$labelCount.Location = New-Object System.Drawing.Point(20, 100)
$labelCount.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($labelCount)

# Increase Button
$btnIncrease = New-Object System.Windows.Forms.Button
$btnIncrease.Text = "+"
$btnIncrease.Location = New-Object System.Drawing.Point(230, 100)
$btnIncrease.Size = New-Object System.Drawing.Size(30, 23)
$btnIncrease.Add_Click({
    $episodeCount++
    $labelCount.Text = "Episodes to Copy: $episodeCount"
})
$form.Controls.Add($btnIncrease)

# Decrease Button
$btnDecrease = New-Object System.Windows.Forms.Button
$btnDecrease.Text = "-"
$btnDecrease.Location = New-Object System.Drawing.Point(270, 100)
$btnDecrease.Size = New-Object System.Drawing.Size(30, 23)
$btnDecrease.Add_Click({
    if ($episodeCount -gt 1) {
        $episodeCount--
        $labelCount.Text = "Episodes to Copy: $episodeCount"
    }
})
$form.Controls.Add($btnDecrease)

# Copy Button
$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text = "Start Copy"
$btnCopy.Location = New-Object System.Drawing.Point(20, 140)
$btnCopy.Add_Click({
    if (-not (Test-Path $sourcePath) -or -not (Test-Path $destPath)) {
        $labelStatus.Text = "Error: Please select both folders."
        return
    }

    $allEpisodes = Get-ChildItem -Path $sourcePath -Include *.mp4, *.mkv -File | Sort-Object Name
    $existingEpisodes = Get-ChildItem -Path $destPath -Include *.mp4, *.mkv -File | Sort-Object Name

    $lastEpisodeCopied = if ($existingEpisodes.Count -gt 0) {
        $existingEpisodes[-1].Name
    } else {
        ""
    }

    $startIndex = if ($lastEpisodeCopied -ne "") {
        ($allEpisodes.Name -indexof $lastEpisodeCopied) + 1
    } else {
        0
    }

    $episodesToCopy = $allEpisodes[$startIndex..([Math]::Min($startIndex + $episodeCount - 1, $allEpisodes.Count - 1))]

    foreach ($episode in $episodesToCopy) {
        Copy-Item -Path $episode.FullName -Destination $destPath
    }

    $labelStatus.Text = "Copied $($episodesToCopy.Count) episode(s)!"
})
$form.Controls.Add($btnCopy)

# Show Form
[void]$form.ShowDialog()
