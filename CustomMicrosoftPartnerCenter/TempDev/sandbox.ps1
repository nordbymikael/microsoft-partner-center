function TestFnc {
    param(
    [Parameter(Mandatory)]
    [ValidateCount(0,5)]
    [AllowEmptyCollection()]
    [System.Object[]]$tst
    )
    return $tst
}

function TestFnc {
    param(
    [Parameter(Mandatory)]
    [System.Guid]$tst
    )
    return $tst.gettype()
}

