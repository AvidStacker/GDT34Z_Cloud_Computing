# Lab 3 – PowerShell: File Signature Analysis

## Introduction

The purpose of this lab is to develop a PowerShell script that analyzes files based on their **file signatures (magic numbers)** and compares them to their file extensions.

This technique is commonly used in **system administration and digital forensics** to detect tampered or suspicious files.

The script performs the following:

* Read file signatures from a configuration file
* Recursively scan a directory
* Identify file types based on binary content
* Map file extensions to expected file types
* Classify files as **VALID**, **ROGUE**, or **UNKNOWN**

---

## Environment and Tools

* PowerShell 7
* Visual Studio Code with PowerShell Extension
* Test files from `ps.7z`

---

## Signature File Structure

The signature file (`siglist.txt`) contains file types with their corresponding headers and optional footers:

```txt
PE;4D5A;
JPEG;FFD8;FFD9;
PDF;25504446;
ZIP;504B;
DB3;53514C69;
```

Each row follows the format:

```
FileType;Header;Footer
```

---

## Methodology

The script performs the following steps:

1. Load file signatures and convert them into byte arrays
2. Dynamically determine header and footer lengths
3. Recursively scan the target directory
4. Read only the beginning and end of each file
5. Compare file signatures using byte-level matching
6. Map file extensions to expected types
7. Compute SHA256 hashes
8. Classify files based on results

---

## Running the Script

Execute the script in PowerShell:

```powershell
.\filesig.ps1
```

---

## Example Output

Below is the output from running the script:

```
[OK] cons.exe → VALID PE
[BAD] cons.txt → ROGUE PE
[BAD] demo.bmp → ROGUE JPEG
[OK] demo.jpg → VALID JPEG
[BAD] ioping...docx → ROGUE ZIP
[OK] ioping...zip → VALID ZIP
[OK] Programming_stick_guide.pdf → VALID PDF
[OK] sms.db3 → VALID DB3
[BAD] mex.dll → ROGUE JPEG
[WARN] several files → NOT PRESENT IN FILE SIGNATURE LIST
```

Summary:

```
Total files scanned : 16
Valid files         : 6
Rogue files         : 4
Unknown files       : 6
```

---

## Analysis

The results clearly demonstrate how file signatures can reveal the true nature of files regardless of their extensions.

Key observations:

* Several files such as `.exe`, `.jpg`, `.zip`, `.pdf`, and `.db3` were correctly identified as **VALID**
* Multiple files were identified as **ROGUE**, including:

  * `.txt` file containing executable data
  * `.bmp` file containing JPEG data
  * `.docx` file identified as ZIP (expected behavior since DOCX is ZIP-based)
  * `.dll` file containing JPEG data
* This indicates **file mangling**, where files are renamed to disguise their true content
* A number of files were classified as **UNKNOWN**, including:

  * Script files (`.ps1`)
  * Text files (`.txt`)
  * Other unsupported formats

These results confirm that relying solely on file extensions is unreliable in security-sensitive environments.

---

## Limitations

* Only analyzes file headers and footers
* Dependent on accuracy of `siglist.txt`
* Does not inspect full file structure

---

## Improvements

Possible improvements include:

* Supporting more file types
* Exporting results to a file
* Parallel processing

---

## Conclusion

The script successfully identifies mismatches between file content and file extensions using file signature analysis.

It demonstrates how file signatures can be used to detect manipulated or suspicious files in a system.

---

## Feedback

### a) Relevance

The lab is relevant as it provides practical experience with file signature analysis and highlights the risks of relying on file extensions.

### b) Suggested Improvements

It would be interesting to include learning or usage of tools that can filter and analyze data based on binary structures, similar to Windows Registry tools. This could give a deeper understanding of how low-level data inspection is applied in real-world systems.

---
