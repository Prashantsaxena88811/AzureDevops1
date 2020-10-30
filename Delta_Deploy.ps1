######xml file reading 
if((Test-Path -Path codepkg))
{
 Remove-Item -Path codepkg -Force -Recurse
}
[xml]$xml = Get-Content "src\package.xml" 
[array]$arraylist = $xml.package.types 
$sourcepath='src'
$sourcefile=''
$destinationpath='codepkg'
######excel file reading
$csv= Import-Csv "MappingCsv.csv"
######creating or using the destination folder
if(!(Test-Path -Path $destinationpath))
{
      New-Item -ItemType directory -Path $destinationpath
}

#####looping folders(name tag) like apexclass,apexpage based on xml

foreach ($folderarray in $arraylist)
{
   $foldername=$folderarray.name

#####looping files(members tag) for respective folder(apexclass) based on xml
   foreach ($filearray in $folderarray.members)
   {
     $filename=$filearray

    #####looping excel sheet 1 rows to get the source folder name
		for($i=1;$i -le $csv.Rows.count;$i++)
		{

		  #1 aita type 2 aita foldername
		   #write-host $csv.Cells($i,2).Value2
		   ##########################################################################  
			 if($foldername -eq $csv.Types[$i])
			{
				if($csv.Filetype[$i] -eq "Folder")
				{
				$sourcefile=$sourcepath+'\'+$csv.FolderName[$i]+'\'+$filename
				}
				else
				{
				$sourcefile=$sourcepath+'\'+$csv.FolderName[$i]+'\'+$filename+'.'+'*'
				}
			   if($sourcefile.Length -gt 0)
				{
					$destinationpath_final=''
					$destinationpath_final=$destinationpath+'\'+$csv.FolderName[$i]
					$filename_extra=$filename.split(".")[0]
					$sourcefile_extra=$sourcepath+'\'+$csv.FolderName[$i]+'\'+$filename_extra+'.'+'*'
					$destinationpath_extra=$destinationpath_final+'\'+$filename.split("/")[0]
					###create a new folder in the destination
					if(!(Test-Path -Path $destinationpath_final))
					{
						New-Item -ItemType directory -Path $destinationpath_final
					}
					if($csv.Filetype[$i] -eq "FileFolder")
					{
						if(!(Test-Path -Path $destinationpath_extra))
						{
						$sourcefilemeta=$sourcepath+'\'+$csv.FolderName[$i]+'\'+$filename.split("/")[0]+'-meta.'+'xml'
						New-Item -ItemType directory -Path $destinationpath_extra
						Copy-Item -path $sourcefilemeta $destinationpath_final
						}
					Copy-Item -path $sourcefile $destinationpath_extra -Force -Recurse
					}

                    if($csv.Filetype[$i] -eq "EmailFolder")
					{
                       New-Item -ItemType directory -Path $destinationpath_extra -Force
                       Copy-Item -Path $sourcefile $destinationpath_extra -Force -Recurse
					}

                    elseif($csv.Filetype[$i] -eq "FileSpecific")
					{
						Copy-Item -path $sourcefile_extra $destinationpath_final -Force -Recurse
					}
					else
					{
						Copy-Item -path $sourcefile $destinationpath_final -Force -Recurse
					}
				}
			############################################################################
			}
		}
	}
}
Copy-Item -Path src\package.xml $destinationpath

Remove-Item -Path $sourcepath -Force -Recurse