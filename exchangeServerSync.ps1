$host.ui.RawUI.WindowTitle = "Exchange Server Sync"

Invoke-Command -ComputerName mbts-dc1 -ScriptBlock {
    
    import-module DirSync
    Start-OnlineCoexistenceSync
    
    }