# OUTLINE SLIDE PRESENTASI — STUDIO PROYEK 3
## Fine-Tuning Transformer Pretrained untuk Klasifikasi Sentimen Bahasa Indonesia (SmSA)

**Kelompok:** [X] — [Nama Anggota 1] ([NIM 1]), [Nama Anggota 2] ([NIM 2])
**Batas:** maksimal **15 slide** (alur mengikuti Bab 10 panduan.md)
**Format akhir:** `Slide_Presentasi_Kelompok[X].pptx`

> **ATURAN ISI SLIDE**
> - Slide itu pendamping bicara, bukan dokumen. **Maksimal 5–7 kata per sel tabel**, hindari jargon.
> - Sasaran penonton: penguji non-RPL → "awam tapi formal".
> - Setiap angka di slide **wajib** berasal dari `rekap_agregat_smsa.csv` hasil run sendiri.
> - Siapkan 1 slide cadangan (backup, tidak dihitung) untuk pertanyaan tersering penguji.

---

## Alur 15 Slide

| No. | Judul Slide | Isi Utama | Sumber Data |
|:---:|:---|:---|:---|
| **1** | Judul & Anggota Kelompok | Judul Studio 3, nama anggota, NIM, kelas | — |
| **2** | Latar Belakang & Masalah | Analisis sentimen Indonesia di industri; akurasi tertinggi belum tentu paling layak | Bab 1 panduan |
| **3** | Backbone yang Dibandingkan | Tabel: IndoBERT vs mBERT vs DistilBERT (kosakata, jumlah parameter, korpus) | Bab 6.1 |
| **4** | Strategi Fine-Tuning | Diagram: Full vs Partial Freezing vs Linear Probing (mana yang dibekukan) | Bab 6.2 |
| **5** | Rancangan & Hipotesis | Matriks 27 run, variabel terkunci, H1–H3 | sel Rancangan |
| **6** | Kurasi & Distribusi Dataset | Diagram 3 tahap pembersihan + grafik ketimpangan kelas | output SEL 4 |
| **7** | Setup & Reproduksibilitas | GPU T4, protokol seeding, FP16/AMP | output SEL 2 |
| **8** | Hasil Utama: Performa | Tabel + bar chart Akurasi & Macro F1 (Mean ± Std) | `rekap_agregat_smsa.csv` |
| **9** | Bukti H1 | Selisih IndoBERT vs mBERT dibandingkan std antar-seed; penjelasan tokenisasi | tabel 3.1 laporan |
| **10** | Efisiensi Komputasi | Grafik waktu latih & memori puncak per run | `rekap_agregat_smsa.csv` |
| **11** | Efisiensi vs Performa (H3) | Seberapa layak partial freezing & linear probing (Δ F1 vs Δ waktu) | tabel 3.1 laporan |
| **12** | Trade-off Latensi Real-Time | Scatter Macro F1 vs latensi (ms/kalimat); peran DistilBERT | grafik panel 3 |
| **13** | Rekomendasi Skenario Industri | 3 skenario → konfigurasi pilihan + alasannya | Bab 8 PR3 |
| **14** | Analisis Kesalahan | Confusion matrix; kesulitan kelas `neutral` (minoritas) | prediksi run terbaik |
| **15** | Kesimpulan & Q&A | 3 poin penutup + status hipotesis | — |
| _(B)_ | Cadangan | Jawaban siap pakai: kenapa 128 token? kenapa 3 seed? kenapa macro F1? | — |

---

## Persiapan Angka per Slide (isi setelah run selesai)

Ambil dari `rekap_agregat_smsa.csv`, jangan hitung manual:

| Yang dibutuhkan | Kolom di CSV |
|:---|:---|
| Akurasi & Macro F1 per kombinasi | `accuracy` (mean, std), `f1_macro` (mean, std) |
| Waktu latih | `train_time_s` (mean, std) |
| Latensi inferensi | `latency_ms` (mean, std) |
| Memori puncak | `peak_memory_mb` (mean, std) |
| Jumlah parameter dilatih | `total_params`, `trainable_params` |

Rumus pembanding keunggulan antar-backbone (untuk Slide 9):
`selisih rata-rata antar-backbone` vs `simpangan baku antar-seed`.
Nyatakan eksplisit: selisih lebih besar dari std → bukan kebetulan seed.

---

## Pembagian Tugas (contoh, sesuaikan)

| Bagian | Slide | Penanggung Jawab |
|:---|:---|:---|
| Latar belakang, dataset, rancangan | 2–6 | [nama] |
| Setup & hasil performa | 7–9 | [nama] |
| Efisiensi, trade-off, rekomendasi | 10–13 | [nama] |
| Analisis kesalahan & kesimpulan | 14–15 | [nama] |

Total run 27 → pembagian eksekusi notebook bisa 9 run per anggota.
