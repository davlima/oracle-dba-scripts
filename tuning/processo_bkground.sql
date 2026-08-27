SELECT b.name, b.description, p.spid AS linux_pid, p.program
FROM v$bgprocess b
JOIN v$process p ON b.paddr = p.addr
WHERE b.paddr <> '00'
ORDER BY b.name;