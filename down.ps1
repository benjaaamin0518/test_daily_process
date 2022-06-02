class dailyProcess{
  static [string] $subtotal;
  static [string] $projectSubtotal;
  static [string] $head;
  static [string] $headMonth;
  static [string] $dailyTable;
  static [string] $currentDirectory;
  static [object[]] $projectArr;

  [string] $inputDir;
  [string] $projectDir;
  [string] $readmePth;
  [decimal] $indirectWork;
  [int] $fileCnt;
  [decimal] $directWork;
  [decimal] $sum;
  [int] $year;
  [int] $month;
  [int] $day;
  [string] $dailyPth;
  [string[]] $dailyData;
  [int] $i;
  dailyProcess(){
    $this.inputDir="./input";
    $this.projectDir="./project";
    $this.readmePth="./README.md";
    $this.fileCnt=(Get-ChildItem $this.inputDir | ? { ! $_.PsIsContainer }).Count;
    $this.indirectWork=0;
    $this.directWork=0;
    $this.sum=0;
    $this.year=(Get-Date).Year;
    $this.month=(Get-Date).Month;
    $this.day=(Get-Date).Day;
    $this.dailyData=@();
    $this.i=0;
  }
  [void] createReadmeFile(){
    if($this.sum -ge 0.1){
      $sonota_g=[decimal] $this.sum-($this.directWork+$this.indirectWork);
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="# 小計";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| 　作業　 | 　工数　 |";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| ------------- | ------------- |";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| 　直接　  | 　$($this.directWork)  |";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| 　間接　  | 　$($this.indirectWork)  |";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| 　その他　  | 　$sonota_g  |";
      [dailyProcess]::subtotal+="`n";
      [dailyProcess]::subtotal+="| 　合計  | 　$($this.sum)  |";
    }
    [string] $ProjectSubtotal_head="";
    $ProjectSubtotal_head+="`n";
    $ProjectSubtotal_head+="`n";
    $ProjectSubtotal_head+="  # 案件";
    $ProjectSubtotal_head+="`n";
    $ProjectSubtotal_head+="| 　案件　 | 　工数　 |　最終更新日　 |";
    $ProjectSubtotal_head+="`n";
    $ProjectSubtotal_head+="| ------------- | ------------- | ------------- |";
    [dailyProcess]::projectSubtotal=$ProjectSubtotal_head+[dailyProcess]::projectSubtotal;
    [string] $result=[string] [dailyProcess]::head+[dailyProcess]::headMonth+[dailyProcess]::subtotal+[dailyProcess]::projectSubtotal+[dailyProcess]::dailyTable;
    New-Item $this.readmePth -Value $result;
  }
  [bool] createReadmeValue(){
    [int] $headMonth=0;
    $nowYear=$this.year;
    $nowMonth=$this.month;
    $nowDay=$this.day;
    while($this.fileCnt -gt $this.i){
      $this.dailyPth=[string] $this.inputDir+"\"+$this.year+"_"+$this.month+"_"+$this.day+".md";
      $timeSpan= [datetime]"${nowYear}/${nowMonth}/${nowDay}" - [datetime]"$($this.year)/$($this.month)/$($this.day)" ;
        if ($($timeSpan.TotalDays) -eq 367) {
        write-host "本日以降の日付のファイルが存在するため処理が正しく行われませんでした。→"$($timeSpan.TotalDays);
        return $false;
       }
      if(Test-Path $this.dailyPth){
        $nowYear=$this.year;
        $nowMonth=$this.month;
        $nowDay=$this.day;  
        [string] $dailyLink=[string] $this.year+"_"+$this.month+"_"+$this.day+".md";
        [string] $forWeekdayStr = ([datetime]([string] $this.year+"/"+$this.month+"/"+$this.day)).ToString("ddd");
        if(($this.i -eq 0) -and ($headMonth -ne $this.month)){
          [dailyProcess]::headMonth=[string] " [$($this.month)月](#$($this.month)月)";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="# <span id='$($this.month)月'>$($this.month)月</span>";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="| 　日付　 | 　工数　 |";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="| ------------- | ------------- |";
          $headMonth=$this.month;
        }
        $this.dailyData= Get-Content $this.dailyPth  -Encoding UTF8;
        [string] $daily=$this.dailyData[0];
        [String] $daily_path= "# "+$this.year+"/"+$this.month+"/"+$this.day;
        If(-not($daily -eq $daily_path)){
          $this.dailyData[0]=$daily_path;
        }
        $this.createProjectValue();
        [dailyProcess]::dailyTable+="`n";
        [dailyProcess]::dailyTable+="| 　[$($this.month)/$($this.day)($forWeekdayStr)](input/$dailyLink)　  | 　$($this.dailyData[3])  |";
        $this.i++;
      }
      $dayDatatime=[datetime]"$($this.year)/$($this.month)/$($this.day)";
      $dayAdd=$dayDatatime.AddDays(-1);
      $this.day=$dayAdd.day;
      if($dayAdd.month -ne $this.month){
        if($headMonth -ne $this.month){
          [dailyProcess]::headMonth=[string] " [$($this.month)月](#$($this.month)月)"+[dailyProcess]::headMonth;
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="# <span id='$($this.month)月'>$($this.month)月</span>";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="| 　日付　 | 　工数　 |";
          [dailyProcess]::dailyTable+="`n";
          [dailyProcess]::dailyTable+="| ------------- | ------------- |";
          $headMonth=$this.month;
        }
        $this.month=$dayAdd.month;
        $this.year=$dayAdd.year;
      }
    }
    return $true;
  }
  [void] createProjectFile(){
    foreach($pro in [dailyProcess]::projectArr){
      $p_r=$($pro.project_name).split("[");
      if($p_r.Length -ge 2){
        $p_r=[string]$p_r[1];
        $p_r=$p_r.split("]");
        $p_r=[string]$p_r[0];
      }
      elseif($($pro.project_name) -ne ""){
        $p_r=$($pro.project_name);
      }
      $filepath=[string]$this.projectDir+"\"+$p_r+".md";
      if(Test-Path $filepath){
        Remove-Item -Path $filepath;
      }
      $pro_count=0;
      $head_project="";
      $s_kousu=[decimal] $pro.g_kousu-($pro.c_kousu+$pro.k_kousu);
      $head_project+="# $p_r";
      $head_project+="`n";
      $head_project+="`n";
      $head_project+="# 小計";
      $head_project+="`n";
      $head_project+="`n";
      $head_project+="| 　作業　 | 　工数　 |";
      $head_project+="`n";
      $head_project+="| ------------- | ------------- |";
      $head_project+="`n";
      $head_project+="| 　直接　  | 　$([decimal]$pro.c_kousu)　  |";
      $head_project+="`n";
      $head_project+="| 　間接　  | 　$([decimal]$pro.k_kousu)  |";
      $head_project+="`n";
      $head_project+="| 　その他　  | 　$s_kousu  |";
      $head_project+="`n";
      $head_project+="| 　合計  | 　$([decimal]$pro.g_kousu)  |";
      $sonota_str="";
      $chokusetsu_str="";
      $kansetsu_str="";
      if($s_kousu -ge 0.1){
        $sonota_str=[string] "その他:${s_kousu}"
      }
      if($([decimal]$pro.c_kousu) -ge 0.1){
        $chokusetsu_str=[string] "直接:$([decimal]$pro.c_kousu) "
      }
      if($([decimal]$pro.k_kousu) -ge 0.1){
        $kansetsu_str=[string] "間接:$([decimal]$pro.k_kousu) "
      }
      $project_md=[string]"project/"+[string] $p_r+".md";
      $sings=[string] $($pro.g_kousu)+"($chokusetsu_str$kansetsu_str$sonota_str)";
      [dailyProcess]::projectSubtotal+="`n";
      [dailyProcess]::projectSubtotal+="| 　[$p_r](${project_md})  | 　$sings  | 　$($pro.date[$pro_count])　  |";
      $b_date="";
      $date_md="";
      foreach($ele in $pro.date){
        $date_md=[string]"../input/"+$ele.replace("/","_")+".md";
        if($pro_count -eq 0){
          $head_project+="`n";
          $head_project+="`n";
          $head_project+="# [$ele]($date_md)";
          $head_project+="`n";
          $head_project+="| 　内容　 | 　作業　 |　工数　 |";
          $head_project+="`n";
          $head_project+="| ------------- | ------------- | ------------- |";
          $head_project+="`n";
          $head_project+="| 　$($pro.name[$pro_count])  | 　$($pro.genre[$pro_count])　  | 　$($pro.kousu[$pro_count])　  |";
        }
        elseif(($b_date -ne "") -and ($b_date -ne $ele)){
          $head_project+="`n";
          $head_project+="`n";
          $head_project+="# [$ele]($date_md)";
          $head_project+="`n";
          $head_project+="| 　内容　 | 　作業　 |　工数　 |";
          $head_project+="`n";
          $head_project+="| ------------- | ------------- | ------------- |";
          $head_project+="`n";
          $head_project+="| 　$($pro.name[$pro_count])  | 　$($pro.genre[$pro_count])　  | 　$($pro.kousu[$pro_count])　  |";
        }
        else{
          $head_project+="`n";
          $head_project+="| 　$($pro.name[$pro_count])  | 　$($pro.genre[$pro_count])　  | 　$($pro.kousu[$pro_count])　  |";
        }
        $b_date=[string]$ele;
        $pro_count++;
      }
      New-Item $filepath -Value $head_project
    }
  }
  [void] createProjectValue(){
    [int] $x=0;
    [decimal]   $kansetsu=0;
    [decimal] $chokusetsu=0;
    [decimal] $goukei=0;

    foreach($ele in $this.dailyData){
      if(($x -ge 8) -and ($ele -ne "")){
        [string[]] $name_arr=@();  
        [string[]] $date_arr=@();  
        [string[]] $kousu_arr=@();
        [string[]] $genre_arr=@();
        [int]  $project_flg=0;
        [string]  $genre="";
        [decimal] $kousu=0;
        [string[]]   $3blab=$ele.split("|");
        if($3blab.Length -ge 1){
          $genre=[string]$3blab[3];
          $kousuStr=[string]$3blab[4];
          $kousu=[decimal]$kousuStr.Trim();
          $project=[string]$3blab[2];
          $project=[string]$project.Trim();
          $name=[string]$3blab[1];
          $name=[string]$name.Trim();
          $genre=[string]$genre.Trim();
          $date_arr+="$($this.year)/$($this.month)/$($this.day)";
          $date="$($this.year)/$($this.month)/$($this.day)";
          $name_arr+=$name;
          $kousu_arr+=$kousu;
          $genre_arr+=$genre;
          $c_kousu=[decimal]0;
          $k_kousu=[decimal]0;
          if($genre -eq "間接"){
            $kansetsu=$kansetsu+$kousu;
            $k_kousu=$kousu;   
          }
          elseif($genre -eq "直接"){
            $chokusetsu=$chokusetsu+$kousu;
            $c_kousu=$kousu;
          }
          else{
            $goukei=$goukei+$kousu;
          }
          $p_r=$project.split("[");
          if($p_r.Length -ge 2){
            $p_r=[string]$p_r[1];
            $p_r=$p_r.split("]");
            $p_r=[string]$p_r[0];
          }
          elseif($project -ne ""){
            $p_r=$project;
          }
          $ddir="../project/"+[string] $p_r+".md";
          if(([string]$project -ne "")-and ($project -ne [string]"[$p_r]($ddir)")){
            $this.dailyData[$x]=[string] "| 　$name  | 　[$p_r]($ddir)　 | 　$genre  | 　$kousu  |";
            $project=[string]"[$p_r]($ddir)";
          }    
          $p_count=0;
          foreach($pro in [dailyProcess]::projectArr){
            if($pro.project_name -eq $project){
              [dailyProcess]::projectArr[$p_count].genre+=$genre;
              [dailyProcess]::projectArr[$p_count].name+=$name;
              [dailyProcess]::projectArr[$p_count].date+=$date;
              [dailyProcess]::projectArr[$p_count].kousu+=$kousu;
              [dailyProcess]::projectArr[$p_count].c_kousu=$c_kousu+[dailyProcess]::projectArr[$p_count].c_kousu;
              [dailyProcess]::projectArr[$p_count].k_kousu=$k_kousu+[dailyProcess]::projectArr[$p_count].k_kousu;
              [dailyProcess]::projectArr[$p_count].g_kousu=$kousu+[dailyProcess]::projectArr[$p_count].g_kousu;
              $project_flg=1;
            }
            $p_count++;
          }
          if(($project_flg -eq 0) -and ($project -ne "")){

            [dailyProcess]::projectArr +=New-Object -TypeName PSObject -Property @{
            name =$name_arr
            date = $date_arr
            kousu = $kousu_arr
            genre= $genre_arr
            c_kousu= $c_kousu
            k_kousu= $k_kousu
            g_kousu=$kousu
            project_name= $project
            }
          }
        }
      }
      $x++;
    }
    $goukei=[decimal] $goukei+$kansetsu+$chokusetsu;
    $sonota=[decimal] $goukei-($kansetsu+$chokusetsu);
    $sonota_str="";
    $chokusetsu_str="";
    $kansetsu_str="";
    if($sonota -ge 0.1){
      $sonota_str=[string] "その他:${sonota}"
    }
    if($chokusetsu -ge 0.1){
      $chokusetsu_str=[string] "直接:${chokusetsu} "
    }
    if($kansetsu -ge 0.1){
      $kansetsu_str=[string] "間接:${kansetsu} "
    }
    $this.dailyData[3]=[string]$goukei+"($chokusetsu_str$kansetsu_str$sonota_str)";
    $this.dailyData | Set-Content -Encoding UTF8 $this.dailyPth;
    $this.indirectWork=[decimal] $this.indirectWork+$kansetsu;
    $this.directWork=[decimal] $this.directWork+$chokusetsu;
    $this.sum=[decimal] $this.sum+$goukei;
  }
  [void] timeDifferenceCalculation(){
    $UTC=(Get-Date);
    $JAPAN=$UTC.AddHours(9);
    Write-host $JAPAN;
    $this.year=$JAPAN.Year;
    $this.month=$JAPAN.Month;
    $this.day=$JAPAN.Day;
  }
  [void] createDailyProcess(){
    $this.timeDifferenceCalculation();
    write-host "UTC:"(Get-Date)
    write-host "日本:$($this.year)/$($this.month)/$($this.day)"
    $createReadmeValue=$this.createReadmeValue();
    if($createReadmeValue -eq $true){
    $this.createProjectFile();
    $this.createReadmeFile();
    }
  }
}
[dailyProcess]::currentDirectory=$PSScriptRoot;
[dailyProcess]::projectSubtotal="";
[dailyProcess]::subtotal="";
[dailyProcess]::projectArr=@();

[dailyProcess]::headMonth="";
[dailyProcess]::dailyTable="";
$DailyProcess=[dailyProcess]::new();

[dailyProcess]::head+="# 1日ごとの工数";
[dailyProcess]::head+="`n";
[dailyProcess]::head+="`n";
[dailyProcess]::head+="## $($DailyProcess.year)年";

if(Test-Path $DailyProcess.readmePth){
     Remove-Item -Path $DailyProcess.readmePth;
 }
if(Test-Path $DailyProcess.projectDir){
    Remove-Item $DailyProcess.projectDir -Recurse
}

New-Item $DailyProcess.projectDir -itemType Directory;
$DailyProcess.createDailyProcess();
write-host $DailyProcess.sum;
