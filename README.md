
# sru-serializer-xqm

This software package provides an XQuery module developed at the Digital Academy of the Academy of Sciences and Literature | Mainz that may be used to build elements of an [OASIS SRU endpoint](http://docs.oasis-open.org/search-ws/searchRetrieve/v1.0/searchRetrieve-v1.0-part0-overview.html).

# Requirements
The module was developed and tested to be used with the versions 3.1 of XQuery.

# How to Use
1. Import the module into your own XQuery script or module in the usual way:

```xquery
import module namespace sru-serializer="http://mwb.adwmainz.net/exist/fcs/sru-serializer" at "PATH/TO/sru-serializer.xqm";
```

2. Use the following variables:
  * `$sru-serializer:basic-params`
  * `$sru-serializer:default-query-type`
  * `$sru-serializer:default-supported-versions`

3. Use the following functions:
  * `sru-serializer:get`
  * `sru-serializer:get-diagnostic`
  * `sru-serializer:get-echoed-request-version`
  * `sru-serializer:get-explain-record`
  * `sru-serializer:get-explain-response#2`
  * `sru-serializer:get-explain-response#3`
  * `sru-serializer:get-next-record-position`
  * `sru-serializer:get-number-of-records`
  * `sru-serializer:get-operation`
  * `sru-serializer:get-record`
  * `sru-serializer:get-scan-response`
  * `sru-serializer:get-scan-version#2`
  * `sru-serializer:get-scan-version#1`
  * `sru-serializer:get-search-retrieve-response`
  * `sru-serializer:get-version#1`
  * `sru-serializer:get-version#2`

---

# License
The software is published under the terms of the MIT license.


# Research Software Engineering and Development

Copyright 2023 <a href="https://orcid.org/0000-0002-5843-7577">Patrick Daniel Brookshire</a>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
