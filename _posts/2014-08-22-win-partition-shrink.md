---
layout: post
title: "Shrinking Windows Partitions Past 50%"
---

I've been on a bit of a SSD kick lately.  The prices have finally dropped low enough that I can justify a moderately sized SSD in each of my commonly used machines.  Unfortunately, my previous "big giant spinning disk for everything" build strategy can be problematic when transitioning to a smaller SSD for the OS and a larger disk for data.  NTFS file layout issues, in particular, can be tough when moving to a new partition that is less than half the size of your old partition.  

Here is the process I have been using:

## Step 1 - Back Up!

Obviously, you need to back up your data before attempting any of these techniques.  We are going to be fiddling with partition maps and file system metadata and the chance for catastrophic data loss is sky high.  Back up anything you're not willing to lose before proceeding.

## Step 2 - Try It and See

There is a slight chance that everything will line up an you will be able to shrink to your desired size on your first try.  If not, this will give you a good idea of the amount of work ahead.

1. Start -> Run -> "diskmgmt.msc"
2. Right Click on the partition you would like to shrink and select "Shrink Volume"

    ![Disk Management](/images/01_diskmgmt_shrink.png)

3. Windows will scan your disk and show you your maximum shrink amount

    ![Shrink Amount](/images/02_shrink.png)

## Step 3 - Review Preliminary Results

 If this is far enough, congratulations!  Shrink the disk and you're set to jump to Step 6.  If not, open up the event viewer to review the blocking file(s).

1. Start -> Run -> "eventvwr.msc"
2. Expand: Windows Logs -> Application
3. Open the second most recent event in the "Defrag" source.  It should include text like the following:

    ```
A volume shrink analysis was initiated on volume (C:). This event log entry details information about the last unmovable file that could limit the maximum number of reclaimable bytes.
 
 Diagnostic details:
 - The last unmovable file appears to be: \System Volume Information\{74c24b89-2a53-11e4-9c81-080027beebb3}{3808876b-c176-4e48-b7ae-04046e6cc752}::$DATA
 - The last cluster of the file is: 0x664cff
 - Shrink potential target (LCN address): 0x27a9c6
 - The NTFS file flags are: ---AD
 - Shrink phase: <analysis>
 
 To find more details about this file please use the "fsutil volume querycluster \\?\Volume{60c383dd-2295-11e4-aeb2-806e6f6e6963} 0x664cff" command.
    ```

## Step 4 - Prepare OS for Defragmentation

Regardless of the blocking file, disabling a few OS features will get rid of quite a few unmovable files before we begin defragmentation.

1. Disable Page File
    1. Start -> Run -> "sysdm.cpl"
    2. Advanced Tab
    3. Performance Section -> Settings
    4. Advanced Tab
    5. Virtual memory Section -> Change
    6. Uncheck "Automatically manage paging file size for all drives"
    7. Select the drive you want to shrink
    8. Select the "No paging file" radio button

        ![Disable Paging](/images/04_disable_paging.png)

    9. Click "Set"
    10. Click Ok until all dialogs are closed and reboot

2. Disable System Protection
    1. Start -> Run -> "sysdm.cpl"
    2. System Protection Tab
    3. Select the drive you want to shrink in the Protection Settings section
    4. Click "Configure"
    5. Select the "Turn off system protection" radio button

        ![Disable System Protection](/images/05_disable_system_protection.png)

    6. Click OK, verify that you are sure, and reboot for good measure


## Step 5 - Defragment

It's time to compact our data now that a large chunk of system files have been removed.

1. Download and install [MyDefrag](http://www.mydefrag.com/Manual-DownloadAndInstall.html) (freeware)
2. Launch MyDefrag and enable the checkbox for the disk you would like to shrink
3. Select the "Analyze only" option and click "Run"

    ![Analysis Results](/images/06_initial_analysis_results.png)

4. Review your results.  In my example, my disk looks pretty good.  The problem files look to be the only issues in the way of a shrink.  A more heavily used disk will probably look much worse.
5. Navigate back to the main MyDefrag screen and pick a defragmentation option
    1. "Consolidate free space" is good if you just need to move a few files around the problem area
    2. "System Disk Monthly" will thoroughly defragment the system but will probably run for quite a while
6. Run your chosen defragmentation option

    ![Defrag Results](/images/07_defrag_results.png)

7. Re-attempt a shrink (see step 2)

    ![Shrink After Defrag](/images/08_shrink_after_defrag.png)

The "consolidate free space" defragmentation strategy yielded excellent results on my demo machine.  As you can see, I was able to recover almost all the free space in my partition.  Shrinking this disk should give me plenty of room on the new, faster, and smaller disk.

## Possible Additional Step - PerfectDisk Defragmentation

MyDefrag isn't always able to provide a clean shrink.  In these cases, it's time to bring in the big guns.  [PerfectDisk](http://www.raxco.com/business/products/perfectdisk-professional) by Raxco includes a boot time defragmentation tool that can clean up tenacious system files.  It also has a free trial.

1. Download and install [PerfectDisk](http://www.raxco.com/business/products/perfectdisk-professional)
2. Launch PerfectDisk

    ![PerfectDisk](/images/09_perfect_disk.png)

3. Click the "Boot Time Defrag" icon and restart

    ![PerfectDisk Boot Time Defrag](/images/10_perfect_disk_boot_time.png)

4. Shrink again (see step 2)

## Step 6 - Copy Data to New Disk

It's time to copy data now that the source partition is small enough to fit on the new drive.  If the source partition is still not small enough, repeating the defragmentation and shrink steps above may help.

We're going to use the [GParted Live CD](http://gparted.org/livecd.php) to move our boot and Windows partition.

1. Download the [GParted Live CD](http://gparted.org/livecd.php) and install it to your medium of choice
2. Boot into GParted
3. Select the boot partition ("System Reserved", 100 megs) on your source drive and click "Copy"

    ![GParted Copy](/images/11_gparted_copy.png)

4. Navigate to your target disk and click "Paste"
5. Navigate back to your source disk, select your Windows partition, and click "Copy"
6. Navigate to your target disk and click "Paste"
7. Ensure that your target disk contains both your boot and Windows partition as follows.  We will expand the partitions later.

    ![GParted before Copy](/images/12_gparted_apply.png)

8. Click "Apply" and wait for your data to copy
    1. This link should help if GParted complains that "This disk contains mismatched GPT and MBR partitions": [Clonezilla to image SSD fails with MBR/GPT mismatch - Overclockers UK Forums](http://forums.overclockers.co.uk/showthread.php?t=18545787)
9. Shut the machine down and remove your source disk

## Step 7 - Booting the New Disk

At this point, your system may boot up and run correctly.  If not, we will use a Windows install or repair disk to clean up the boot information.

1. Shut down the machine
2. Boot to the Windows install or repair disk
3. Choose "Repair your computer" at the install screen

    ![Repair your computer](/images/13_repair_computer.png)

4. Select the "Use recovery tools" radio button
5. Click "Next >"

    ![System Recovery Options](/images/14_recovery_options.png)

6. Click "Startup Repair"
7. Allow the repair process to run.  Click "Finish" when complete.

## Step 8 - Restoring Functionality

1. Now that the new disk is back up and running, you will want to reverse the steps taken to disable System Protection and the page file in Step 4
2. Additionally, you should be able to increase the size of the main partition to the rest of the disk via the "Extend Volume" functionality on the disk context menu in the Disk Management screen

    ![Extend Volume](/images/16_extend_volume.png)

## Conclusion

I hope this long and rambling guide is useful to other folks.  I know that I'll probably use it myself in the near future.
