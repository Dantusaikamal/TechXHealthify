import 'package:flutter/material.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/themes/app_styles.dart'; // Make sure this includes your ColorConstant and AppStyle definitions.

class NewsArticlesScreen extends StatelessWidget {
  const NewsArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Article text (approximately 500 words) with basic Markdown-like formatting.
    const String articleText = '''
Healthify: Revolutionizing Cardiac Care through Wearable Technology

In today's fast-paced digital era, the intersection of technology and healthcare is no longer a distant dream but a reality that is reshaping the landscape of medical care. Healthify, a state-of-the-art mobile application, exemplifies this transformation by harnessing the power of wearable devices and advanced data analytics to provide real-time cardiac monitoring and early stroke detection.

Healthify integrates seamlessly with popular smart bands and smartwatches through the Google Fit API, ensuring continuous tracking of a user's heart rate. Using advanced machine learning algorithms, the app learns the individual’s normal heart rate patterns and identifies any significant deviations—either spikes or drops—that could signal an impending heart stroke. When such an abnormality is detected, the app immediately prompts the user with a clear question: “Are you experiencing a heart stroke?” If the user confirms distress or fails to respond within a critical 10-second window, Healthify automatically sends an emergency alert along with the user's precise location to nearby hospitals and designated contacts.

This proactive approach is a significant shift from traditional cardiac care, where detection often happens only after symptoms have worsened. By providing real-time insights and a rapid response system, Healthify has the potential to reduce critical delays in emergency care, thereby improving patient outcomes. In situations where every second counts, such immediate action can be life-saving.

Privacy and data security are at the forefront of Healthify’s design. The application employs robust encryption protocols to safeguard sensitive personal and health-related information. All data transmissions are secured, and the app complies with international standards such as GDPR and HIPAA. Users can be confident that their personal data, including their heart rate and location, is handled with the utmost care and responsibility.

The user interface of Healthify is designed with both functionality and aesthetics in mind. A sleek, intuitive dashboard displays daily activity metrics, heart rate trends, and other vital statistics in a visually appealing manner. Interactive graphs and clear visual cues make it easy for users to understand their health data at a glance. This intuitive design not only enhances user engagement but also empowers individuals to take charge of their health.

Furthermore, Healthify’s seamless integration with emergency services sets a new standard for mHealth applications. By automating the alert process and ensuring that emergency responders receive timely, accurate information, the app acts as a critical lifeline during cardiac events. This integration highlights how wearable technology, when paired with smart algorithms, can bridge the gap between preventative health monitoring and emergency medical care.

By leveraging the latest advancements in wearable technology and artificial intelligence, Healthify is more than just an application—it is a comprehensive health management platform. The app’s personalized insights and rapid emergency response capabilities pave the way for a future where healthcare is proactive rather than reactive. As more users adopt this technology, Healthify is poised to become a trusted companion in the fight against cardiovascular diseases, ultimately helping to save lives.

In conclusion, Healthify represents a bold step forward in modern healthcare. Its innovative blend of continuous monitoring, intelligent data analysis, and immediate emergency response redefines what is possible in cardiac care. With Healthify, the future of personalized, technology-driven healthcare is here, promising a safer and healthier tomorrow for everyone.
    ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Article"),
        backgroundColor: ColorConstant.bluedark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstant.whiteBackground,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.shadowColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title of the article.
              Text(
                "Healthify: Revolutionizing Cardiac Care through Wearable Technology",
                style: AppStyle.txtPoppinsBold28Dark,
              ),
              const SizedBox(height: 20),
              // Article content with basic formatting.
              Text(
                articleText,
                style: AppStyle.txtPoppinsSemiBold16DarkGray,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
