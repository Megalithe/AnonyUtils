# AnonyUtils
Scripts to support troubleshooting AU application issues. Includes log parsers, diagnostics and misc tasks.

# AuServiceHealthCheck.sh

# GenerateUserCredentials.sh
Made this quick script to create X amount of random usernames and passwords which are outputted to a text file. This was created to address a specific recurring request for a job to create trial accounts.

Dependencies
Leverages "APG" - Automated Password Generator

-a 1: Use algorithm 1 (pronounceable passwords)
-M ncl: Exclude capital letters (n), lowercase letters (c), and symbols (l) - though this seems contradictory since you'd need some character types
-n 1: Generate 1 password
-m 8: Minimum length of 8 characters
-E iIlL1oO0B8 Exclude these specific characters (i, I, l, L, 1, o, O, 0, B, 8, ))

# AnonyOsxLogViewer.sh

# AnonyOsxDiagnostic.sh

# AnonyWindowsDiagnostic.cmd
