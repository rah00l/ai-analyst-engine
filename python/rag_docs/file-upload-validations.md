# File Upload Validations

## Mandatory Field Checks

When a payment file is uploaded, the system first verifies that all required fields have been provided. The mandatory fields are: the Region and Affiliate Network selection (which identifies which network this payment is from), the Deposit Date (the date the payment was received in the bank account), the Deposit Amount (the total payment amount), and the Network Payment ID (the unique identifier the network assigned to this payment). If any of these fields are left blank or incomplete, the system displays an error and prevents the upload from proceeding. These fields are essential because they provide the context needed to correctly parse and reconcile the payment file.

## Unique Payment ID Validation

The system checks that the Network Payment ID has not been used before. Each payment from a network should have a unique identifier — reusing a payment ID would indicate either a duplicate upload (the same payment file being loaded twice) or a data entry error. If the payment ID already exists in the system, an error message appears explaining that this payment has already been recorded. Similarly, the system checks that the uploaded filename is unique — uploading a file with the same name as a previously uploaded file triggers a duplicate warning. These checks prevent double-counting of payments.

## Deposit Amount Format Validation

The Deposit Amount field must contain a valid numeric value representing a currency amount. The system rejects entries that contain letters, special characters (other than a decimal point), or are formatted in a way that cannot be interpreted as a number. This validation prevents data entry errors where someone might accidentally type a date in the amount field, include a currency symbol, or paste formatted text. The system expects a plain decimal number representing the deposit amount in the relevant currency.

## Supported File Formats

The payment reconciliation system accepts payment files in the following formats: XML, JSON, XLS, XLSX, and CSV. Each affiliate network has a specific expected file format — for example, AffiliateWindow and DGM use CSV files, eBay uses XLSX, Linkshare uses XML, and Commission Junction and Impact Radius use XLS. If a file in an unsupported format is uploaded (such as a PDF, a plain text file, or an image), the system displays an error and prevents processing. The file format matters because the parser uses format-specific logic to extract transaction data from each file type.

## What Happens After Successful Upload

Once all validations pass, the payment file is uploaded to cloud storage and a new record is created in the system with a status of NEW. The file details — region, affiliate network, deposit date, deposit amount, payment ID, and filename — are displayed in the Payment File Status List table on the upload screen. From this point, the user can click the Parse button to move the file to READY status, which queues it for backend processing. The file will then be picked up by the automated parsing job, which runs periodically, and processed through the column-mapping and transaction-matching pipeline.
