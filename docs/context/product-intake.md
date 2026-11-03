# Product intake

NF-e XML is parsed in Ruby. A label photo or a paper invoice is sent to the smart model and must come back as JSON. Neither path writes a product or a stock movement.

Confirmation stays on the existing create and `PATCH .../stock` endpoints. ADMIN and CASH_REGISTER can upload (`:intake, :inventory`). The label and document endpoints also require AI to be on. A reply that is not the expected JSON is `ai_invalid_output` (502). A file that is not a readable JPEG, PNG, PDF, or NF-e XML, or that is over 5 MB, is `invalid_document` (422).

Uploads are not stored. JPEG and PNG bytes are stripped of EXIF before they leave the server.
