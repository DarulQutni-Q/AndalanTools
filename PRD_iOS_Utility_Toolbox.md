# PRD — Aplikasi Utility Tools Offline (iOS-first, lalu Android)

Dokumen ini ditulis untuk AI coding agent yang akan riset, adaptasi source/logic open-source, dan membangun aplikasi ini. Semua rekomendasi package/reference di bawah sudah dicek per 6 September 2026 — tetap verifikasi ulang versi & status maintenance sebelum dipakai, karena ekosistem package bergerak cepat.

## 0. Ringkasan

Aplikasi mobile offline yang mengumpulkan beberapa utility tools dalam satu app:
1. Image to PDF (gabung banyak gambar jadi 1 PDF, dari galeri maupun kamera)
2. Custom free-form crop setelah upload gambar
3. Compress ukuran file (gambar/PDF besar jadi kecil)
4. PDF editor dengan OCR
5. Konversi Word/docx ke PDF dan sebaliknya
6. Tambahan: convert format gambar (HEIC/PNG/JPG/WebP), split/reorder/hapus halaman PDF

Semua proses jalan 100% di device (tidak ada upload ke server manapun). Prioritas: pakai package/logic open-source yang sudah ada, jangan bangun dari nol kalau tidak perlu.

**Target awal:** personal use di iPhone 12 (iOS terbaru), builder tidak punya Mac sama sekali.
**Target jangka panjang:** publish ke App Store dan Play Store.

## 1. Constraints Kunci (WAJIB dibaca sebelum mulai coding)

- Builder tidak punya akses Mac sama sekali. Daily driver: Linux (Arch-based/CachyOS).
- Device target: iPhone 12, iOS versi terbaru.
- Tidak boleh online/cloud processing — semua fitur harus jalan offline, tanpa API key berbayar.
- Semua fitur harus disusun dari source/logic open-source yang sudah ada (riset dulu, baru adaptasi), bukan ditulis dari nol tanpa referensi.
- Kalau reference project sumbernya untuk Linux/Python/desktop dan tidak bisa jalan langsung di iOS, ambil **logika/algoritmanya saja**, lalu tulis ulang di bahasa yang bisa dipakai di iOS (Swift atau Dart).

## 2. Keputusan Arsitektur: Flutter (Dart)

**Rekomendasi: Flutter**, bukan Swift native murni. Alasan:

- Karena tujuan akhir adalah iOS **dan** Android dari satu codebase, dan builder tidak punya Mac, Flutter jauh lebih efisien dibanding maintain 2 codebase native (Swift + Kotlin).
- Flutter iOS build **bisa dilakukan tanpa Mac** lewat cloud CI/CD (lihat Bagian 3) — ini pola yang sudah lazim dipakai developer Windows/Linux tanpa Mac.
- Ekosistem pub.dev punya banyak package siap pakai untuk hampir semua fitur yang diminta (image crop, compress, PDF, OCR) — cocok dengan prinsip "jangan build dari nol".
- Kalau builder lebih suka Swift native murni: tetap technically bisa lewat cloud Mac (Codemagic/MacinCloud dsb), tapi maintenance Android jadi proyek terpisah total. Tidak direkomendasikan untuk kasus ini kecuali app store publish HANYA untuk iOS selamanya.

AI agent: konfirmasi ulang pilihan ini di awal kerja, tapi kecuali ada alasan kuat, jalan dengan Flutter.

## 3. Strategi Build & Distribusi Tanpa Mac

### 3.1 Jalur A — Pakai sendiri sekarang (gratis, tanpa Apple Developer Program)

1. Push project Flutter ke GitHub/GitLab.
2. Daftar **Codemagic** (CI/CD cloud yang punya Mac di server mereka) — hubungkan repo. Codemagic historis punya free tier bulanan (menit build gratis); cek halaman pricing mereka untuk kuota terkini. Alternatif: GitHub Actions dengan `macos-latest` runner (menit macOS ditagih lebih mahal dari menit Linux/Windows, tapi juga bisa dipakai gratis dalam kuota terbatas).
3. Konfigurasi `codemagic.yaml` untuk build `.ipa` iOS. Untuk pemakaian pribadi, build tidak perlu disign lewat sertifikat Apple Developer Program berbayar — cukup hasilkan `.ipa` yang nanti disign ulang secara lokal.
4. Untuk instal ke iPhone dari Linux tanpa Mac tanpa Windows: pakai **SideStore** (fork dari AltStore, open source, AGPL v3). Setup awal butuh komputer sekali saja (di Linux, lewat Docker/AltServer-Linux) untuk pairing device; setelah itu SideStore bisa refresh/reinstall app langsung dari iPhone lewat VPN tunnel tanpa perlu komputer lagi. SideStore sign app pakai Apple ID gratis (bukan paid developer account) — app tetap kena batas sertifikat personal (refresh berkala otomatis oleh SideStore, jadi tidak perlu manual re-sign tiap 7 hari).
5. Alternatif lain kalau SideStore di Linux merepotkan: jalankan VM Windows sekali untuk setup awal Sideloadly/AltServer, lalu pindah ke SideStore untuk pemakaian harian.

Ini jalur **Rp0** untuk mulai — cocok untuk tahap development & testing personal sebelum yakin mau lanjut publish.

### 3.2 Jalur B — Publish ke App Store + Play Store (nanti)

1. Daftar **Apple Developer Program** — USD 99/tahun, pendaftaran 100% lewat browser di developer.apple.com, tidak butuh Mac. (Catatan: paid membership ini tetap wajib untuk code signing distribusi/App Store, tidak ada cara resmi lain.)
2. Daftar **Google Play Console** — USD 25 sekali bayar (bukan tahunan), juga lewat browser.
3. Setup Codemagic **automatic code signing**: generate App Store Connect API key dari Apple Developer portal (lewat browser, tanpa Mac), masukkan ke Codemagic — Codemagic otomatis bikin certificate + provisioning profile, build, sign, dan upload langsung ke **TestFlight**. Ini jalur paling mulus: tidak perlu urus ipa/sideload manual lagi setelah setup ini beres.
4. Untuk Android, build `.aab` lewat Codemagic/GitHub Actions bisa dilakukan di runner Linux biasa (tidak butuh Mac sama sekali), lalu upload ke Play Console.
5. TestFlight bisa dipakai duluan untuk beta testing (builder sendiri + circle terbatas) sebelum submit review App Store publik.

### 3.3 Catatan penting

- Free Apple ID (tanpa bayar $99) hanya bisa install maksimal ~3 app personal per device, expiry sertifikat 7 hari (di-refresh otomatis oleh SideStore). Ini cukup untuk tahap development, TIDAK cocok jadi strategi distribusi jangka panjang.
- Jangan andalkan AltStore/SideStore untuk versi final yang dipublikasi — itu murni jalur testing pribadi. Publish resmi tetap lewat App Store/Play Store dengan akun berbayar di atas.
- Apple Developer Program **tidak butuh Mac untuk didaftarkan maupun untuk dipakai bareng Codemagic** — poin ini sudah dikonfirmasi berkali-kali di riset, jadi tidak perlu beli/pinjam Mac di titik manapun kalau pakai Flutter + Codemagic.

## 4. Struktur Proyek (saran)

```
lib/
  core/            # file manager, storage service, theme, shared utils
  features/
    image_to_pdf/
    crop/
    compress/
    pdf_editor/
    ocr/
    docx_converter/
    image_format_converter/
  shared/
    widgets/
```

State management: bebas dipilih AI agent, tapi **Riverpod** disarankan (dipakai juga di reference app "Split PDF" pada Bagian 6.5) karena ringan dan umum dipakai di project sejenis.

## 5. Spesifikasi Fitur & Reference Open-Source

### 5.1 Image to PDF (kamera + galeri, merge, custom free crop, compress)

**User story:** User ambil beberapa foto (dari kamera dalam-app atau galeri), urutkan, crop bebas kalau perlu, compress, lalu gabung jadi satu file PDF.

Rekomendasi komponen (kombinasi beberapa package, bukan satu package all-in-one):

| Sub-fitur | Package/reference | Catatan lisensi & sumber |
|---|---|---|
| Kamera scan dokumen (auto edge-detect, multi-page) | `flutter_doc_scanner` (pub.dev) | Wrapper resmi untuk **Google ML Kit Document Scanner** (Android) dan **Apple VisionKit `VNDocumentCameraViewController`** (iOS) — keduanya API bawaan OS, on-device, gratis. Bisa langsung keluarkan hasil sebagai PDF atau gambar per halaman. |
| Custom free-form crop | `image_cropper` (pub.dev, by Yalantis) | Membungkus **TOCropViewController** (open-source Swift, MIT, oleh Tim Oliver) untuk iOS dan **uCrop** (open-source, Apache-2.0) untuk Android. Sudah mendukung freeform crop + aspect ratio preset + rotasi. Ini persis contoh "ambil dari open-source project" yang diminta — logic crop-nya memang dari 2 library open-source tsb. |
| Compress gambar | `flutter_image_compress` (a.k.a. `image_compress_plus` — nama baru setelah rename) | Native binding kompresi gambar Android/iOS, kontrol quality/maxWidth/maxHeight. |
| Gabung gambar/PDF jadi satu PDF | `pdf_combiner` (GitHub: vicajilau/pdf_combiner) | Cross-platform (Android/iOS/Linux/macOS/web). Di iOS diimplementasikan native Swift tanpa dependency eksternal. Bisa gabung PDF+gambar campur dalam satu file, urutan bebas. |
| PDF generation tingkat rendah (kalau perlu custom layout) | package `pdf` (dart_pdf, GitHub: DavBfr/dart_pdf) | Library dasar pembuatan PDF di Dart, MIT, dipakai luas sebagai fondasi banyak tools PDF Flutter lain. |

**Acceptance criteria:**
- User bisa pilih multi-gambar dari galeri ATAU foto langsung dari kamera dalam app, dicampur dalam satu sesi.
- Urutan halaman bisa diatur ulang (drag reorder) sebelum digabung.
- Setiap gambar bisa di-crop bebas (bukan cuma rasio tetap) sebelum digabung.
- User bisa pilih level compress sebelum export PDF final.
- Output: satu file PDF valid, bisa dibuka di app Files/PDF viewer lain.

### 5.2 PDF Editor + OCR

**User story:** User buka PDF yang sudah ada, bisa split/reorder/hapus halaman, tambah watermark/password, dan menjalankan OCR untuk ekstrak teks (misalnya dari hasil scan).

| Sub-fitur | Package/reference | Catatan |
|---|---|---|
| OCR (ekstrak teks dari gambar/scan) | `google_mlkit_text_recognition` (pub.dev, publisher resmi flutter-ml.dev, MIT) | Jalan **on-device**, sekali model ke-download tidak butuh internet lagi. Mendukung karakter Latin (cukup untuk Bahasa Indonesia + Inggris). Ini pilihan paling praktis dibanding porting Tesseract manual. |
| Split/reorder/delete halaman PDF | `pdf_combiner` (fitur extract), atau `pdf_splitern`, atau `pdf_manipulator` (Rust engine, MIT, fitur lengkap: merge/split/render/extract/sign/encrypt) | `pdf_manipulator` masih relatif baru (rilis pertengahan 2026) — cek dulu stabilitas & jumlah adopter sebelum dipakai sebagai dependency utama. |
| Viewer/edit PDF lebih lengkap (annotate, form fill, watermark, password) | `syncfusion_flutter_pdf` + `syncfusion_flutter_pdfviewer` | **Bukan open-source murni** — source-available komersial, tapi ada **Community License gratis** untuk yang gross revenue < USD 1 juta/tahun dan tim < 5 developer < 10 karyawan (Darul memenuhi syarat ini). Kalau ingin 100% open-source/permissive tanpa daftar community license, pertimbangkan `pdfrx` (MIT, berbasis PDFium) untuk viewing, dikombinasi `pdf_manipulator`/`pdf_combiner` untuk manipulasi. |

**Acceptance criteria:**
- User bisa hapus, susun ulang, dan split halaman dari PDF yang sudah ada.
- User bisa jalankan OCR pada gambar atau halaman PDF hasil scan, dapat teks yang bisa di-copy.
- (Opsional v1, boleh v2) tambah password/watermark ke PDF.

### 5.3 Konversi Docx ⇄ PDF

Ini bagian **paling sulit** secara teknis — perlu ekspektasi realistis di awal.

**Fakta penting dari riset:** di iOS (beda dengan macOS), `NSAttributedString` bawaan Apple **tidak** bisa baca format `.docx` secara native (cuma didukung di macOS, itu pun terbatas). Jadi tidak ada jalan pintas API native Apple untuk fitur ini — harus dibangun sendiri dari komponen open-source.

**Docx → PDF (arah lebih mudah):**
1. File `.docx` sebenarnya adalah ZIP berisi file XML. Unzip pakai package `archive` (Dart, standar), lalu parse `word/document.xml` untuk ambil teks, heading, bold/italic, bullet list. Bisa reuse pendekatan dari package seperti `docx_to_text` sebagai referensi cara parsing.
2. Hasil parsing di-render jadi PDF pakai package `pdf` (dart_pdf) dengan widget system-nya (Text, Header, Bullet, dsb).
3. Hasil: PDF dengan struktur teks yang benar, TAPI **tidak pixel-perfect** sama persis layout Word aslinya (font eksotis, tabel kompleks, gambar posisi presisi kemungkinan tidak identik).

**PDF → Docx (arah lebih sulit):**
1. Reference logic: **pdf2docx** (github.com/ArtifexSoftware/pdf2docx, Python, MIT license, sekarang community-maintained). Project ini extract data PDF pakai PyMuPDF, parse layout berbasis rule (section, paragraph, image, table), lalu generate docx pakai python-docx.
2. Karena ini Python (tidak bisa jalan langsung di iOS), **ambil logika/alurnya saja**: (a) extract text block + posisi per halaman, (b) kelompokkan jadi paragraf berdasarkan aturan spasi/posisi, (c) deteksi heading vs body text dari ukuran font, (d) tulis ulang sebagai docx.
3. Untuk step "tulis docx" di Swift/iOS, referensi: **DocX-Swift** (github.com/shinjukunian/DocX, MIT) — library Swift yang convert `NSAttributedString` jadi file `.docx`. Bisa dipakai sebagai basis writer setelah proses ekstraksi teks selesai.
4. **Set ekspektasi user di UI**: hasil v1 fokus ke "teks & struktur dasar bisa diedit lagi di Word", bukan replika visual 100%. Ini konsisten dengan limitasi yang disebutkan pdf2docx sendiri di dokumentasinya ("rule-based method can't 100% convert the PDF layout").

**Acceptance criteria v1:**
- Docx sederhana (teks, heading, bullet list, bold/italic) berhasil jadi PDF yang terbaca rapi.
- PDF berbasis teks (bukan hasil scan gambar) berhasil jadi docx yang bisa dibuka & diedit di Word/Google Docs, isi teks benar, heading/paragraf terpisah dengan wajar.
- Ada disclaimer di UI soal keterbatasan fidelity.

### 5.4 Convert Format Gambar (HEIC/PNG/JPG/WebP)

Pakai package `image` (Dart, pure-Dart, lisensi permissive) untuk decode/encode antar format. Untuk HEIC dari iPhone, iOS punya dukungan native decode HEIC yang bisa dimanfaatkan lewat `image_picker`/platform channel sebelum masuk ke pipeline `image`. AI agent: verifikasi dukungan encode WebP di versi terbaru package `image` sebelum final — kalau kurang stabil, pertimbangkan native platform channel (CoreImage di iOS sudah bisa encode WebP/HEIC).

### 5.5 Split / Reorder / Delete Halaman PDF

Sudah dicakup di Bagian 5.2 (satu paket dengan PDF editor) — gunakan `pdf_combiner` atau `pdf_splitern`.

**Reference app open-source yang relevan sebagai contoh arsitektur:** repo GitHub `rahul31124/Split-PDF` — aplikasi Flutter open-source yang fiturnya sangat mirip (split, merge, compress, image-to-pdf, lock PDF), pakai Riverpod + GoRouter + Syncfusion PDF + PDFx. Baik dipelajari strukturnya sebagai starting point, meskipun bukan berarti harus 100% dicontek.

### 5.6 Saran Fitur Tambahan (opsional, prioritas rendah — evaluasi bareng user)

Karena diminta untuk kasih usul, berikut beberapa yang menurut saya cukup berguna untuk app kategori ini:

- **Share extension / "Open In"**: app ini muncul sebagai target share dari app lain (misal share foto dari Galeri langsung ke app ini). Sangat menambah kenyamanan penggunaan sehari-hari.
- **Integrasi Files app (iOS)**: file hasil konversi muncul di app Files bawaan iOS, bukan cuma tersimpan di dalam sandbox app.
- **Password/encrypt & remove password PDF.**
- **Watermark & tanda tangan digital (draw signature) di PDF** — sudah ter-cover sebagian oleh Syncfusion/pdf_manipulator kalau dipakai.
- **Batch processing**: compress/convert banyak file sekaligus, bukan satu-satu.
- **Riwayat/file manager dalam app** supaya user gampang balik ke hasil sebelumnya tanpa cari manual di Files.
- **Dark mode.**
- **Apple Shortcuts integration**: jalankan salah satu tool (misal "compress gambar ini") lewat Shortcuts/Siri tanpa buka app dulu.

## 6. Non-Functional Requirements

- Semua pemrosesan wajib on-device — tidak ada network call untuk fitur inti manapun (OCR, compress, convert, dsb).
- Proses berat (compress banyak file, OCR, convert docx) dijalankan di isolate/background thread supaya UI tidak freeze.
- Tidak ada data user yang keluar device — ini juga jadi nilai jual privasi saat listing di App Store/Play Store nanti (privacy label "Data Not Collected").
- Perhatikan batas memori untuk gambar resolusi tinggi dari kamera iPhone 12 (12MP) supaya tidak crash saat proses beberapa gambar sekaligus.

## 7. Instruksi Riset & Sourcing untuk AI Agent

Ikuti alur ini setiap kali mengerjakan satu fitur:

1. Cek pub.dev dulu untuk package yang cocok (list awal sudah ada di Bagian 5). Verifikasi: tanggal update terakhir (idealnya < 12 bulan), pub points/likes, dan eksplisit mendukung iOS.
2. Kalau package pub.dev membungkus native library open-source (contoh: `image_cropper` -> TOCropViewController), baca source native-nya kalau butuh kustomisasi di luar API yang diekspos package.
3. Kalau reference terbaik untuk suatu masalah cuma ada di project non-mobile (Python/Linux/dsb, contoh: pdf2docx), JANGAN coba jalankan/compile project itu di iOS. Baca algoritmanya, lalu tulis ulang logikanya dari nol di Dart/Swift.
4. Sebelum menambah dependency baru, cek lisensinya:
   - MIT/BSD/Apache-2.0 → aman dipakai sebagai dependency, boleh juga pelajari & port logikanya.
   - GPL/AGPL → hati-hati kalau app ini rencananya closed-source: pakai sebagai dependency terpisah (bukan copy-paste source ke dalam project) umumnya masih aman, tapi menyalin kode sumbernya langsung ke project bisa mewajibkan project ini ikut open-source (copyleft). Kalau ragu, pelajari cara kerjanya lalu tulis ulang sendiri (clean-room), jangan copy-paste.
   - Source-available komersial dengan free tier (contoh: Syncfusion) → catat syarat free tier-nya (revenue/jumlah developer) supaya tidak kelewat dipakai di luar syarat itu.
5. Catat semua keputusan sourcing (nama project, versi, lisensi, alasan pilih) di file `CREDITS.md` di root project.

## 8. Roadmap

**Fase 0 — Setup:** init project Flutter, repo GitHub, akun Codemagic, tentukan nama app & bundle identifier, setup SideStore di mesin Linux untuk instal ke iPhone.

**Fase 1 — MVP personal:** Image to PDF (kamera+galeri, merge, crop bebas, compress). Install & test di iPhone lewat Jalur A (Bagian 3.1).

**Fase 2:** PDF editor (split/reorder/delete/password), OCR.

**Fase 3:** Docx ⇄ PDF (dengan ekspektasi fidelity yang sudah dijelaskan), convert format gambar.

**Fase 4:** Polish (share extension, Files integration, dark mode), build Android, siapkan aset store (icon, screenshot, privacy policy).

**Fase 5:** Daftar Apple Developer Program + Play Console, submit App Store & Play Store.

## 9. Risiko & Open Questions

- **App Store Guideline 4.2 (Minimum Functionality):** Apple kadang menolak app "kumpulan tools generik" yang dianggap template/kurang unik. Mitigasi: pastikan UX jadi satu alur yang kohesif (bukan sekadar 6 tombol terpisah), beri identitas brand yang jelas.
- Fidelity konversi docx⇄pdf terbatas (lihat Bagian 5.3) — perlu disclaimer di UI.
- `pdf_manipulator` masih baru dirilis pertengahan 2026 — pantau stabilitasnya sebelum jadi dependency inti.
- Syncfusion Community License ada syarat (revenue/jumlah developer) yang perlu dipantau kalau proyek berkembang.
- Ekosistem SideStore/AltStore dikelola komunitas pihak ketiga (bukan resmi Apple) — cuma dipakai untuk testing pribadi, bukan strategi distribusi jangka panjang.
- Nama aplikasi & bundle identifier belum ditentukan — perlu diputuskan di Fase 0 karena dipakai di code signing dan listing store.
- Waktu review App Store/Play Store untuk submission pertama bisa 1-2 minggu — jangan submit mepet target tanggal.

## 10. Referensi Utama (ringkas)

- Codemagic — build/sign iOS tanpa Mac: blog.codemagic.io
- SideStore — sideload tanpa komputer setelah setup awal: github.com/JJTech0130/SideStore, docs di nythepegasus.github.io/SideStore-Docs
- image_cropper — pub.dev/packages/image_cropper (wraps TOCropViewController + uCrop)
- flutter_image_compress — pub.dev/packages/flutter_image_compress
- flutter_doc_scanner — pub.dev/packages/flutter_doc_scanner (wraps ML Kit Document Scanner + VisionKit)
- pdf_combiner — github.com/vicajilau/pdf_combiner
- pdf (dart_pdf) — github.com/DavBfr/dart_pdf
- google_mlkit_text_recognition — pub.dev/packages/google_mlkit_text_recognition
- pdf_manipulator — pub.dev/packages/pdf_manipulator
- syncfusion_flutter_pdf / pdfviewer — pub.dev (Community License: syncfusion.com/products/communitylicense)
- pdf2docx (referensi logika PDF→docx) — github.com/ArtifexSoftware/pdf2docx
- DocX-Swift (referensi writer docx native) — github.com/shinjukunian/DocX
- Split-PDF (reference app arsitektur) — github.com/rahul31124/Split-PDF
