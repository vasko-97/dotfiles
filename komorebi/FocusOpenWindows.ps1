# meant to be run on startup from komorebi (or GlazeWM) to activate all windows so komorebi (or GlazeWM) can move them to the appropriate workspace.
# By default komorebi (and GlazeWM) will move newly created windows to the correct workspace, but won't move existing ones until they're made active.

Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public class Window
{
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    public static List<Dictionary<string, string>> GetOpenWindows()
    {
        var windows = new List<Dictionary<string, string>>();

        EnumWindows((hWnd, lParam) =>
        {
            if (IsWindowVisible(hWnd))
            {
                var title = new StringBuilder(256);
                GetWindowText(hWnd, title, 256);

                uint processId;
                GetWindowThreadProcessId(hWnd, out processId);
                var process = Process.GetProcessById((int)processId);

                var window = new Dictionary<string, string>
          {
            { "ProcessName", process.ProcessName },
            { "ProcessID", process.Id.ToString() },
            { "WindowsTitle", title.ToString() },
            { "Handle", hWnd.ToString() }
          };

                windows.Add(window);
            }
            return true;
        }, IntPtr.Zero);

        return windows;
    }
}
"@

[array]$Windows = @()

[Window]::GetOpenWindows() | where WindowsTitle | #has a name
  foreach {
    $item = New-Object PSCustomObject | select ProcessName, ProcessID, WindowsTitle, Handle
    $item.ProcessName = $_.ProcessName
    $Item.ProcessId = $_.ProcessID
    $item.WindowsTitle = $_.WindowsTitle
    $item.Handle = $_.Handle

    $Windows += $item
  }

$Windows | ForEach-Object {
    nircmd win activate handle $_.Handle
    Start-Sleep -Milliseconds 200
}