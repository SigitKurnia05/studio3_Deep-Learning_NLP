// ============================================================================
// STUDIO PROYEK 3: PEMBELAJARAN MENDALAM (IF25-40401)
// Slide Presentasi Typst - High-End Keynote & Visual Metaphor Design
// Kelompok 11 (Kelompok Yolo) · Teknik Informatika ITERA
// ============================================================================

#set document(
  title: "Fine-Tuning Transformer Pretrained untuk Analisis Sentimen SmSA",
  author: ("Sigit Kurnia Hartawan", "Muhammad Romadhon Santoso")
)

// --- PALET WARNA EDITORIAL & TEKNIKAL ---
#let c-midnight    = rgb("#090d16") // Cover dark background
#let c-canvas      = rgb("#f8fafc") // Content background
#let c-surface     = rgb("#ffffff") // Card surface
#let c-border      = rgb("#e2e8f0") // Subtle border
#let c-border-glow = rgb("#cbd5e1")
#let c-primary     = rgb("#0f172a") // Deep Navy / Slate 900
#let c-secondary   = rgb("#1e40af") // Classic Navy Blue 800
#let c-accent      = rgb("#2563eb") // Vibrant Royal Blue 600
#let c-cyan        = rgb("#0284c7") // Sky Cyan 600
#let c-emerald     = rgb("#059669") // Success Emerald 600
#let c-amber       = rgb("#d97706") // Warning Amber 600
#let c-rose        = rgb("#e11d48") // Danger Rose 600
#let c-muted       = rgb("#64748b") // Muted Slate 500

#set text(
  font: ("Segoe UI", "Arial"),
  size: 11pt,
  fill: c-primary
)

#set page(
  paper: "presentation-16-9",
  margin: (x: 1.5cm, top: 1.0cm, bottom: 0.8cm),
  fill: c-canvas,
  footer: [
    #set text(size: 8.5pt, fill: c-muted)
    #grid(
      columns: (1fr, 1fr),
      align(left)[#text(weight: "medium")[Studio Proyek 3 · IF25-40401] #text(fill: c-border)[|] Kelompok 11 (Yolo)],
      align(right)[Teknik Informatika · Institut Teknologi Sumatera]
    )
  ]
)

// --- KOMPONEN DESAIN "FORMAL TAPI BERIKAN SENTUHAN SENI" ---

#let slide-header(category: "STUDIO PROYEK 3", title: "Judul Slide", slide-num: "01") = [
  #v(-0.35cm)
  #grid(
    columns: (1fr, auto),
    gutter: 10pt,
    [
      #text(size: 8.5pt, weight: "bold", fill: c-accent, tracking: 1.5pt)[#upper(category)] \
      #v(1pt)
      #text(size: 17pt, weight: "bold", fill: c-primary)[#title]
    ],
    [
      #align(bottom + right)[
        #box(
          fill: rgb("#e0e7ff"),
          radius: 999pt,
          inset: (x: 8pt, y: 3pt),
          text(size: 8.5pt, weight: "bold", fill: c-secondary)[#slide-num #text(fill: rgb("#93c5fd"))[/] 08]
        )
      ]
    ]
  )
  #v(2pt)
  #line(length: 100%, stroke: 1.2pt + c-accent)
  #v(0.12cm)
]

#let bento-card(title: none, icon-color: c-accent, body) = {
  rect(
    fill: c-surface,
    stroke: 0.8pt + c-border,
    radius: 7pt,
    width: 100%,
    inset: (x: 9pt, y: 7pt),
    [
      #if title != none [
        #grid(
          columns: (auto, 1fr),
          gutter: 6pt,
          align(horizon)[#box(fill: icon-color, width: 4pt, height: 11pt, radius: 2pt)],
          align(horizon)[#text(weight: "bold", size: 11pt, fill: c-primary)[#title]]
        )
        #v(2pt)
        #line(length: 100%, stroke: 0.4pt + c-border)
        #v(3pt)
      ]
      #body
    ]
  )
}

#let stat-callout(number, label, subtext: none, color: c-accent) = {
  rect(
    fill: rgb("#f8fafc"),
    stroke: (left: 3.5pt + color, rest: 0.6pt + c-border),
    radius: (right: 6pt),
    inset: (x: 8pt, y: 5pt),
    width: 100%,
    [
      #text(size: 15pt, weight: "bold", fill: color)[#number] \
      #v(-2pt)
      #text(size: 9pt, weight: "bold", fill: c-primary)[#label]
      #if subtext != none [
        \ #text(size: 8pt, fill: c-muted)[#subtext]
      ]
    ]
  )
}

#let art-banner(body, border-color: c-accent, bg: rgb("#eff6ff")) = {
  rect(
    fill: bg,
    stroke: (left: 3.5pt + border-color, rest: 0.5pt + border-color.lighten(70%)),
    radius: (right: 5pt),
    width: 100%,
    inset: (x: 9pt, y: 5pt),
    text(size: 9.8pt, fill: c-primary)[#body]
  )
}

#let status-pill(label, bg: "#dcfce7", fg: "#166534") = {
  box(
    fill: rgb(bg),
    radius: 999pt,
    inset: (x: 6pt, y: 1.5pt),
    baseline: 0%,
    text(size: 8pt, weight: "bold", fill: rgb(fg))[#label]
  )
}

// ============================================================================
// SLIDE 1: COVER (SOPHISTICATED KEYNOTE WITH 3D TRANSFORMER ARTWORK)
// ============================================================================
#page(
  fill: c-midnight,
  footer: [
    #set text(size: 8.5pt, fill: rgb("#94a3b8"))
    #grid(
      columns: (1fr, 1fr),
      align(left)[#text(weight: "medium")[Pembelajaran Mendalam (IF25-40401)] · Studio Proyek 3],
      align(right)[Institut Teknologi Sumatera · 2026]
    )
  ]
)[
  #v(0.2cm)
  #grid(
    columns: (1.2fr, 0.95fr),
    gutter: 18pt,
    align: (horizon, horizon),
    [
      #box(
        fill: rgb("#1e293b"),
        radius: 999pt,
        stroke: 0.8pt + rgb("#334155"),
        inset: (x: 10pt, y: 3.5pt),
        text(size: 8.5pt, weight: "bold", fill: rgb("#38bdf8"), tracking: 1.5pt)[TRANSFORMER FINE-TUNING · NLP RISET]
      )
      
      #v(0.25cm)
      #text(size: 21pt, weight: "bold", fill: rgb("#ffffff"))[Fine-Tuning Transformer Pretrained untuk Analisis Sentimen Indonesia]
      
      #v(0.1cm)
      #text(size: 11.5pt, fill: rgb("#cbd5e1"))[Studi Komparatif 3 Backbone × 3 Strategi Berbasis Trade-off Performa & Efisiensi Komputasi Nyata]
      
      #v(0.4cm)
      #box(
        fill: rgb("#0f172a"),
        radius: 7pt,
        stroke: 0.8pt + rgb("#1e293b"),
        inset: (x: 14pt, y: 8pt),
        [
          #grid(
            columns: (1fr, 1fr),
            gutter: 14pt,
            [
              #text(weight: "bold", size: 11pt, fill: rgb("#f8fafc"))[Sigit Kurnia Hartawan] \
              #text(size: 9pt, fill: rgb("#94a3b8"))[NIM: 123140033]
            ],
            [
              #text(weight: "bold", size: 11pt, fill: rgb("#f8fafc"))[Muhammad Romadhon S.] \
              #text(size: 9pt, fill: rgb("#94a3b8"))[NIM: 123140031]
            ]
          )
          #v(3pt)
          #line(length: 100%, stroke: 0.4pt + rgb("#334155"))
          #v(2pt)
          #text(size: 9pt, weight: "bold", fill: rgb("#38bdf8"))[Kelompok 11 (Kelompok Yolo)] #text(fill: rgb("#64748b"))[•] #text(size: 9pt, fill: rgb("#94a3b8"))[Teknik Informatika · ITERA]
        ]
      )
    ],
    [
      #align(center)[
        #box(
          radius: 10pt,
          clip: true,
          stroke: 1pt + rgb("#334155"),
          image("cover_transformer_art.jpg", width: 100%)
        )
        #v(3pt)
        #text(size: 7.5pt, fill: rgb("#64748b"), style: "italic")[Ilustrasi Konseptual Arsitektur Multi-Layer Transformer & Semantic Attention]
      ]
    ]
  )
]

// ============================================================================
// SLIDE 2: LATAR BELAKANG & TRILEMMA KOMPUTASI (SOAL 1)
// ============================================================================
#pagebreak()
#slide-header(category: "SOAL 1 — PERSIAPAN SEBELUM NGODING", title: "Latar Belakang, Dataset & Dilema Rekayasa AI", slide-num: "02")

#grid(
  columns: (1.2fr, 0.95fr),
  gutter: 12pt,
  [
    #bento-card(title: "Dataset SmSA & Protokol Anti-Data Leakage", icon-color: c-accent)[
      #set text(size: 9.3pt)
      - *3 Kelas Sentimen:* Positive (*58.4%*), Negative (*31.2%*), Neutral (*10.4%*).
      - *Metrik Utama:* #text(weight: "bold", fill: c-secondary)[Macro F1-Score] (karena kelas netral timpang & menguji batas penalaran semantik).
      - *Pembersihan Ketat:* 0 konflik label, 67 duplikat dibuang, 14 data bocor ke validasi dibersihkan. Himpunan bersih: *10.919 train*, *1.260 valid*.
    ]
    #v(0.1cm)
    #bento-card(title: "Matriks 27 Run Terkendali", icon-color: c-cyan)[
      #set text(size: 9.3pt)
      - *3 Model × 3 Strategi × 3 Seed Acak (42, 123, 2024)*.
      - *Variabel Terkunci:* Batch 32, Max Token 128 (dinamis), 4 Epoch tetap, AdamW ($w_d=0.01$), FP16 Automatic Mixed Precision.
    ]
  ],
  [
    #bento-card(title: "Visual Metaphor: Segitiga Dilema AI Industri", icon-color: c-amber)[
      #align(center)[
        #box(radius: 6pt, clip: true, stroke: 0.5pt + c-border, image("ai_trilemma_metaphor.jpg", height: 3.7cm))
      ]
      #set text(size: 8.5pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        gutter: 4pt,
        align(center)[#text(fill: c-amber, weight: "bold")[🎯 Akurasi\ Puncak]],
        align(center)[#text(fill: c-emerald, weight: "bold")[🍃 Biaya GPU\ Rendah]],
        align(center)[#text(fill: c-cyan, weight: "bold")[⚡ Latensi\ Real-Time]]
      )
      #v(1pt)
      #text(size: 7.8pt, fill: c-muted, style: "italic")[Tantangan Industri: Menyeimbangkan ketiga pilar tanpa membebani server produksi.]
    ]
  ]
)

#v(0.08cm)
#art-banner[
  #text(weight: "bold", fill: c-secondary)[Prinsip Data Science Industri:] Model dengan akurasi tertinggi belum tentu merupakan pilihan terbaik untuk implementasi nyata jika waktu latih GPU dan latensi inferensinya menjadi *bottleneck* operasional.
]

// ============================================================================
// SLIDE 3: BACKBONE & METAFORA LAYER FREEZING (SOAL 2 & 3)
// ============================================================================
#pagebreak()
#slide-header(category: "SOAL 2 & 3 — ARSITEKTUR & FREEZING", title: "Profil Model Backbone & Metafora Layer Freezing", slide-num: "03")

#grid(
  columns: (1.2fr, 0.95fr),
  gutter: 12pt,
  [
    #bento-card(title: "3 Model Backbone Pretrained (Soal 2)", icon-color: c-secondary)[
      #set text(size: 9.3pt)
      + *IndoBERT (`indobert-base-p1`):* 12 lapis, *124.4M param*. Monolingual Bahasa Indonesia (Indo4B: berita, Wikipedia, medsos).
      + *mBERT (`bert-base-multilingual-cased`):* 12 lapis, *177.9M param*. Multilingual 104 bahasa (baseline pembanding global).
      + *DistilmBERT (`distilbert-base-multilingual`):* 6 lapis, *135.3M param*. Versi kompresi arsitektur via *knowledge distillation*.
    ]
    #v(0.1cm)
    #bento-card(title: "3 Strategi Fine-Tuning Teruji (Soal 3)", icon-color: c-accent)[
      #set text(size: 9.3pt)
      + *Full Fine-Tuning:* 100% parameter dilatih (LR = $3 times 10^(-5)$).
      + *Partial Freezing:* Bekukan embedding + 50% layer awal (6 lapis BERT / 3 lapis DistilBERT). Latih 16.2% -- 34.7% param (LR = $3 times 10^(-5)$).
      + *Linear Probing:* 100% backbone beku, hanya latih head (\<0.5% param). LR dinaikkan ke $1 times 10^(-3)$.
    ]
  ],
  [
    #bento-card(title: "Visual Metaphor: Freeze vs Trainable", icon-color: c-cyan)[
      #align(center)[
        #box(radius: 6pt, clip: true, stroke: 0.5pt + c-border, image("layer_freezing_metaphor.jpg", height: 4.1cm))
      ]
      #set text(size: 8.5pt)
      - #text(fill: c-amber, weight: "bold")[Lapisan Atas & Head (Emas):] Tetap aktif beradaptasi khusus ke domain sentimen SmSA.
      - #text(fill: c-cyan, weight: "bold")[Lapisan Bawah (Kristal Es):] Dibekukan untuk memangkas separuh alokasi komputasi & gradien.
    ]
  ]
)

// ============================================================================
// SLIDE 4: REKAPITULASI HASIL AGREGAT (27 RUN)
// ============================================================================
#pagebreak()
#slide-header(category: "EVALUASI EMPIRIS MENYELURUH", title: "Rekapitulasi Hasil Agregat (Mean ± Std dari 27 Run)", slide-num: "04")

#set text(size: 8.8pt)
#table(
  columns: (1.3fr, 1.1fr, 1.25fr, 1.25fr, 1.25fr, 1.35fr, 1.25fr, 1.35fr),
  stroke: 0.5pt + c-border,
  fill: (col, row) => if row == 0 { rgb("#0f172a") } else if row in (1, 4, 7) { rgb("#f1f5f9") } else { none },
  align: (col, row) => if col < 2 { left } else { center },
  
  [#text(fill: white, weight: "bold")[Backbone]],
  [#text(fill: white, weight: "bold")[Strategi]],
  [#text(fill: white, weight: "bold")[Akurasi]],
  [#text(fill: white, weight: "bold")[Macro F1]],
  [#text(fill: white, weight: "bold")[F1 Netral]],
  [#text(fill: white, weight: "bold")[Waktu Latih]],
  [#text(fill: white, weight: "bold")[Latensi]],
  [#text(fill: white, weight: "bold")[VRAM GPU]],
  
  [*IndoBERT*], [*Full*], [*0.9407 ± 0.005*], [*0.9167 ± 0.004*], [*0.8594 ± 0.003*], [217.16 ± 1.6s], [8.77 ± 1.6ms], [3257.96 MB],
  [IndoBERT], [Partial], [0.9349 ± 0.001], [0.9085 ± 0.001], [0.8477 ± 0.004], [121.80 ± 0.3s], [8.18 ± 1.2ms], [1750.08 MB],
  [IndoBERT], [Probing], [0.8865 ± 0.002], [0.8495 ± 0.002], [0.7742 ± 0.007], [55.29 ± 0.1s], [8.54 ± 1.6ms], [582.23 MB],
  
  [*mBERT*], [Full], [0.9148 ± 0.009], [0.8822 ± 0.013], [0.8110 ± 0.023], [287.71 ± 0.4s], [8.11 ± 0.8ms], [3878.14 MB],
  [mBERT], [Partial], [0.8841 ± 0.006], [0.8431 ± 0.004], [0.7574 ± 0.005], [147.77 ± 0.2s], [7.77 ± 0.3ms], [1949.82 MB],
  [mBERT], [Probing], [0.7519 ± 0.001], [0.6362 ± 0.000], [0.4093 ± 0.007], [69.89 ± 0.1s], [9.52 ± 0.8ms], [786.23 MB],
  
  [*DistilmBERT*], [Full], [0.9130 ± 0.005], [0.8767 ± 0.003], [0.7945 ± 0.004], [166.52 ± 0.3s], [*4.65 ± 0.8ms*], [2618.73 MB],
  [DistilmBERT], [Partial], [0.8669 ± 0.002], [0.8172 ± 0.002], [0.7095 ± 0.014], [72.54 ± 0.1s], [4.46 ± 1.0ms], [1181.68 MB],
  [DistilmBERT], [Probing], [0.8140 ± 0.005], [0.7529 ± 0.006], [0.6374 ± 0.009], [*36.37 ± 0.2s*], [4.40 ± 0.5ms], [*622.46 MB*]
)

#v(0.12cm)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 8pt,
  stat-callout("0.9167", "Macro F1 Puncak", subtext: "IndoBERT Full memimpin mutlak", color: c-secondary),
  stat-callout("99.1%", "Retensi Performa", subtext: "IndoBERT Partial (hemat 43.9% waktu)", color: c-emerald),
  stat-callout("4.65 ms", "Latensi Tercepat", subtext: "DistilmBERT 2× lebih responsif", color: c-cyan)
)

// ============================================================================
// SLIDE 5: ANALISIS KINERJA SENTIMEN & KELAS MINORITAS (GRAFIK 1 & 4)
// ============================================================================
#pagebreak()
#slide-header(category: "ANALISIS SEMANTIK BAHASA", title: "Kinerja Sentimen & Ketahanan Kelas Minoritas", slide-num: "05")

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #bento-card(title: "Perbandingan Akurasi & Macro F1 (Grafik 1)", icon-color: c-secondary)[
      #align(center)[#image("grafik_1_akurasi_8e43b7.png", height: 3.9cm)]
      #set text(size: 9.3pt)
      - *Dominasi IndoBERT:* Konsisten paling unggul di semua strategi (F1: 0.9167 $->$ 0.9085 $->$ 0.8495).
      - *mBERT vs Distil Seimbang:* Pada Full mode, Macro F1 praktis setara (0.8822 vs 0.8767, selisih hanya *0.55 poin*).
    ]
  ],
  [
    #bento-card(title: "Ketahanan Sentimen Netral (Grafik 4)", icon-color: c-rose)[
      #align(center)[#image("grafik_4_f1_per_kelas_8e43b7.png", height: 3.9cm)]
      #set text(size: 9.3pt)
      - *Ujian Kelas Netral (10.4%):* IndoBERT Full meraih F1 Netral tertinggi (*0.8594*) vs mBERT (0.8110) & Distil (0.7945).
      - *Keruntuhan Probing:* mBERT probing hancur pada kelas netral (F1 *0.4093*) karena representasi umum multilingual gagal mengenali batas sentimen lokal.
    ]
  ]
)

// ============================================================================
// SLIDE 6: BIAYA KOMPUTASI & LATENSI INFERENSI (GRAFIK 2 & 3)
// ============================================================================
#pagebreak()
#slide-header(category: "ANALISIS EFISIENSI & BENCHMARKING", title: "Efisiensi Komputasi GPU & Kurva Trade-off Latensi", slide-num: "06")

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #bento-card(title: "Waktu Pelatihan & Memori GPU (Grafik 2)", icon-color: c-emerald)[
      #align(center)[#image("grafik_2_biaya_8e43b7.png", height: 3.9cm)]
      #set text(size: 9.3pt)
      - *Partial Freezing Efisien:* Memangkas durasi pelatihan *~44% -- 49%* dan VRAM GPU *~46% -- 50%* pada model BERT 12 lapis.
      - *Linear Probing Ekstrem:* Selesai 36--70s (\< 800 MB VRAM), namun penalti degradasi performa terlalu mahal.
    ]
  ],
  [
    #bento-card(title: "Trade-off Pareto F1 vs Latensi (Grafik 3)", icon-color: c-cyan)[
      #align(center)[#image("grafik_3_tradeoff_8e43b7.png", height: 3.9cm)]
      #set text(size: 9.3pt)
      - *Freezing != Inferensi Cepat:* Membekukan bobot hanya memotong waktu latih, bukan forward pass inferensi.
      - *Distilasi Adalah Kunci:* DistilmBERT 6 lapis mencatat *4.65 ms/kalimat* (hampir 2× lebih cepat dari model 12 lapis di ~8.1--8.8 ms).
    ]
  ]
)

// ============================================================================
// SLIDE 7: PEMBUKTIAN HIPOTESIS & JAWABAN PERTANYAAN RISET
// ============================================================================
#pagebreak()
#slide-header(category: "VALIDASI STATISTIK RISET", title: "Pembuktian Hipotesis & Jawaban Pertanyaan Wajib", slide-num: "07")

#grid(
  columns: (1.15fr, 1fr),
  gutter: 10pt,
  [
    #bento-card(title: "Evaluasi Statistik Hipotesis (H1 -- H3)", icon-color: c-secondary)[
      #set text(size: 9.2pt)
      #table(
        columns: (0.7fr, 2.2fr, 1fr),
        stroke: 0.5pt + c-border,
        align: (col, row) => if col == 2 { center } else { left },
        fill: (col, row) => if row == 0 { rgb("#f1f5f9") } else { none },
        [#strong[Uji]], [#strong[Pengujian & Bukti Empiris]], [#strong[Status]],
        [*H1*], [IndoBERT > mBERT (+3.45 F1, $p=0.0360$)\ IndoBERT > Distil (+4.00 F1, $p=0.0003$)], [#status-pill("TERDUKUNG")],
        [*H2*], [Distil hemat waktu 42.1% & latensi 42.6% vs mBERT; penurunan F1 hanya 0.55 poin], [#status-pill("TERDUKUNG")],
        [*H3*], [Hierarki Full $gt.eq$ Partial > Probing terbukti.\ Partial $gt.eq$ 96% F1 sukses di IndoBERT (99.1%), tapi Distil hanya 93.2%], [#status-pill("BERSYARAT", bg: "#fef3c7", fg: "#92400e")]
      )
      #v(1pt)
      #text(size: 8pt, fill: c-muted)[*Catatan:* Uji signifikansi menggunakan Welch's two-sample t-test ($alpha = 0.05$).]
    ]
  ],
  [
    #bento-card(title: "Jawaban 3 Pertanyaan Riset Wajib", icon-color: c-emerald)[
      #set text(size: 9.3pt)
      + *Backbone Terbaik:* *IndoBERT* unggul mutlak melampaui variasi acak seed ($p < 0.05$) berkat kecocokan korpus teks lokal.
      + *Evaluasi Freezing:* *Partial Freezing sangat sepadan pada IndoBERT* (rugi F1 hanya 0.84 poin, hemat waktu latih 43.9%). Sebaliknya, *Linear Probing tidak sepadan*.
      + *Rekomendasi Nyata:* Terpetakan sesuai constraint sistem industri (lihat Slide 8).
    ]
  ]
)

// ============================================================================
// SLIDE 8: REKOMENDASI INDUSTRI & PENUTUP (ROADMAP DEPLOYMENT)
// ============================================================================
#pagebreak()
#slide-header(category: "IMPLEMENTASI PRODUKSI", title: "Rekomendasi Industri (Deployment Roadmap) & Penutup", slide-num: "08")

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 8pt,
  [
    #bento-card(title: "1. Server Analytics", icon-color: c-emerald)[
      #set text(size: 9pt)
      *Rekomendasi: IndoBERT Full*
      - *Kebutuhan:* Audit regulasi, reputasi eksekutif, komplain nasabah VIP.
      - *Macro F1:* *0.9167* (Neutral: 0.8594).
      - *Alasan:* Akurasi maksimum mutlak ketika salah klasifikasi berisiko fatal.
    ]
  ],
  [
    #bento-card(title: "2. Continuous Retrain", icon-color: c-secondary)[
      #set text(size: 9pt)
      *Rekomendasi: IndoBERT Partial*
      - *Kebutuhan:* Pipeline MLOps mingguan mengikuti tren *slang* e-commerce.
      - *Macro F1:* *0.9085* (Retensi 99.1%).
      - *Alasan:* *Hemat 43.9% waktu* & *46.3% VRAM*; cepat dilatih di GPU murah.
    ]
  ],
  [
    #bento-card(title: "3. Real-Time Streaming", icon-color: c-amber)[
      #set text(size: 9pt)
      *Rekomendasi: DistilmBERT Full*
      - *Kebutuhan:* Moderasi live chat, chatbot instan, edge deployment.
      - *Latensi:* *4.65 ms* (2× lebih cepat).
      - *Macro F1:* *0.8767* (kompetitif).
      - *Alasan:* Mencegah bottleneck latensi pada trafik ribuan request/detik.
    ]
  ]
)

#v(0.12cm)
#rect(fill: rgb("#0f172a"), radius: 7pt, width: 100%, inset: 8pt)[
  #grid(
    columns: (1.3fr, 1.7fr),
    gutter: 14pt,
    [
      #text(weight: "bold", size: 10pt, fill: rgb("#38bdf8"))[Tiga Pelajaran Utama Data Science:] \
      #set text(size: 8.8pt, fill: rgb("#cbd5e1"))
      1. Pretraining monolingual > ukuran parameter model. \
      2. Distilasi arsitektur adalah kunci efisiensi inferensi. \
      3. Partial freezing adalah sweet-spot efisiensi training.
    ],
    [
      #text(weight: "bold", size: 10pt, fill: rgb("#38bdf8"))[Tautan Repositori & Sesi Q&A:] \
      #set text(size: 8.8pt, fill: rgb("#cbd5e1"))
      - *Colab:* #link("https://s.itera.id/ipynb_Studio3-NLP_Kelompok11")[#text(fill: rgb("#93c5fd"))[s.itera.id/ipynb_Studio3-NLP_Kelompok11]] \
      - *Drive:* #link("https://s.itera.id/Drive_Studio3-NLP_Kelompok11")[#text(fill: rgb("#93c5fd"))[s.itera.id/Drive_Studio3-NLP_Kelompok11]] \
      - *GitHub:* #link("https://s.itera.id/Github_Studio3-NLP_Kelompok11")[#text(fill: rgb("#93c5fd"))[s.itera.id/Github_Studio3-NLP_Kelompok11]]
    ]
  )
]
