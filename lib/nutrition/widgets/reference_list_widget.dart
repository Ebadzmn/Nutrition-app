import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';

class ReferenceData {
  final String id;
  final String text;
  final String? note;
  final Map<String, String> links;

  ReferenceData({required this.id, required this.text, this.note, required this.links});
}

final List<ReferenceData> nutritionReferences = [
  ReferenceData(
    id: "1",
    text: "Sarwar R, Niclos BB, Rutherford OM. Changes in muscle strength, relaxation rate and fatiguability during the human menstrual cycle. J Physiol. 1996;493(Pt 1):267–272.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/8735711/",
      "DOI": "https://doi.org/10.1113/jphysiol.1996.sp021381",
    },
  ),
  ReferenceData(
    id: "2",
    text: "Hampson E. Estrogen-related variations in human spatial and articulatory-motor skills. Psychoneuroendocrinology. 1990;15(2):97–111.",
    links: {
      "DOI": "https://doi.org/10.1016/0306-4530(90)90018-5",
    },
  ),
  ReferenceData(
    id: "3",
    text: "Facchinetti F, Borella P, Sances G, Fioroni L, Nappi RE, Genazzani AR. Oral magnesium successfully relieves premenstrual mood changes. Obstet Gynecol. 1991;78(2):177–181.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/2067759/",
    },
  ),
  ReferenceData(
    id: "4",
    text: "Janse de Jonge XAK. Effects of the menstrual cycle on exercise performance. Sports Med. 2003;33(11):833–851.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/12959622/",
      "DOI": "https://doi.org/10.2165/00007256-200333110-00004",
    },
  ),
  ReferenceData(
    id: "5",
    text: "Enns DL, Tiidus PM. The influence of estrogen on skeletal muscle: sex matters. Sports Med. 2010;40(1):41–58.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/20020786/",
      "DOI": "https://doi.org/10.2165/11319760-000000000-00000",
    },
  ),
  ReferenceData(
    id: "6",
    text: "Hewett TE, Myer GD, Ford KR. Anterior cruciate ligament injuries in female athletes: Part 1, mechanisms and risk factors. Am J Sports Med. 2006;34(2):299–311.",
    note: "Published 2006, not 2007 as originally listed.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/16423913/",
      "DOI": "https://doi.org/10.1177/0363546505284183",
    },
  ),
  ReferenceData(
    id: "7",
    text: "Sohrabji F, Lewis DK. Estrogen–BDNF interactions: implications for neurodegenerative diseases. Front Neuroendocrinol. 2006;27(4):404–414.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/17069877/",
      "DOI": "https://doi.org/10.1016/j.yfrne.2006.09.003",
    },
  ),
  ReferenceData(
    id: "8",
    text: "Stokes T, Hector AJ, Morton RW, McGlory C, Phillips SM. Recent perspectives regarding the role of dietary protein for the promotion of muscle hypertrophy with resistance exercise training. Nutrients. 2018;10(2):180.",
    links: {
      "DOI / Full text": "https://doi.org/10.3390/nu10020180",
      "PMC": "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5852756/",
    },
  ),
  ReferenceData(
    id: "9",
    text: "Lebrun CM. Effect of the different phases of the menstrual cycle and oral contraceptives on athletic performance. Sports Med. 1993;16(6):400–430.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/8303141/",
      "DOI": "https://doi.org/10.2165/00007256-199316060-00005",
    },
  ),
  ReferenceData(
    id: "10",
    text: "Elliott KJ, Cable NT, Reilly T, Diver MJ. Effect of menstrual cycle phase on the concentration of bioavailable 17-β oestradiol and testosterone and muscle strength. Clin Sci (Lond). 2003;105(6):663–669.",
    note: "The original citation's title/journal — \"Maximal muscle strength related to electromechanical delay in knee extensors,\" J Electromyogr Kinesiol — could not be located; this is the actual 2003 Elliott et al. paper on menstrual cycle and muscle strength.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/12848619/",
      "DOI": "https://doi.org/10.1042/CS20020360",
    },
  ),
  ReferenceData(
    id: "11",
    text: "Barr SI, Prior JC, Vigna YM. Restrained eating and ovulatory disturbances: possible implications for bone health. Am J Clin Nutr. 1994;59(1):92–97.",
    note: "Published 1994, not 1995. The \"Solomon SJ et al., progesterone and resting metabolic rate\" portion of this combined entry lacked enough detail — author list, year, journal — to locate.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/8279410/",
      "DOI": "https://doi.org/10.1093/ajcn/59.1.92",
    },
  ),
  ReferenceData(
    id: "12",
    text: "Rapkin AJ, Akopians AL. Pathophysiology of premenstrual syndrome and premenstrual dysphoric disorder. Menopause Int. 2012;18(2):52–59.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/22611222/",
      "DOI": "https://doi.org/10.1258/mi.2012.012014",
    },
  ),
  ReferenceData(
    id: "13",
    text: "Charkoudian N, Stachenfeld NS. Reproductive hormone influences on thermoregulation in women. Compr Physiol. 2014;4(2):793–804.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/24715568/",
      "DOI": "https://doi.org/10.1002/cphy.c130029",
    },
  ),
  ReferenceData(
    id: "14",
    text: "Yonkers KA, O'Brien PMS, Eriksson E. Premenstrual syndrome. Lancet. 2008;371(9619):1200–1210.",
    links: {
      "The Lancet": "https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(08)60527-9/abstract",
      "DOI": "https://doi.org/10.1016/S0140-6736(08)60527-9",
    },
  ),
  ReferenceData(
    id: "15",
    text: "Thys-Jacobs S, Starkey P, Bernstein D, Tian J. Calcium carbonate and the premenstrual syndrome: effects on premenstrual and menstrual symptoms. Am J Obstet Gynecol. 1998;179(2):444–452.",
    links: {
      "PubMed": "https://pubmed.ncbi.nlm.nih.gov/9731851/",
      "DOI": "https://doi.org/10.1016/S0002-9378(98)70377-1",
    },
  ),
];

class ReferenceListWidget extends StatelessWidget {
  const ReferenceListWidget({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: nutritionReferences.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_rounded, color: isDark ? Colors.blue[300] : Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Medical Disclaimer: The information and recommendations provided in this app are based on these scientific sources. This information is for educational purposes only and should not replace professional medical advice, diagnosis, or treatment.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.blue[100] : Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final ref = nutritionReferences[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A2E28) : const Color(0xFFFFF5F0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ref.id,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFFB38E) : const Color(0xFFFF8A5C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref.text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white : const Color(0xFF2D2420),
                      ),
                    ),
                  ),
                ],
              ),
              if (ref.note != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: isDark ? Colors.orange[300] : Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ref.note!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.orange[200] : Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ref.links.entries.map((entry) {
                  return InkWell(
                    onTap: () => _launchUrl(entry.value),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceLight : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF444444) : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link,
                            size: 14,
                            color: isDark ? Colors.blue[300] : Colors.blue[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.blue[300] : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
