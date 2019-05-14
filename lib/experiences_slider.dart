import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'model/experience.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'experiences_bloc.dart';
import 'bloc_provider.dart';
import 'experience_view.dart';
import 'experience_bloc.dart';
import 'experience_view.dart';

class ExperiencesSlider extends StatefulWidget {
  String userId;

  ExperiencesSlider({@required this.userId});

  @override
  createState() => ExperiencesSliderState(userId: userId);
}

class ExperiencesSliderState extends State<ExperiencesSlider> {
  SwiperController _swiperController = SwiperController();
  List<Experience> _experiences;
  int _currentIndex = 0;
  String userId;


  ExperiencesSliderState({this.userId});

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ExperiencesSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var experiencesBloc = BlocProvider.of<ExperiencesBloc>(context);

    return StreamBuilder<ExperiencesInfo>(
        stream: experiencesBloc.experiencesStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("No experience"));
          } else {
            var experiencesInfo = snapshot.data;
            _experiences = experiencesInfo.experiences;

            return Swiper(
              key: Key(DateTime.now().toString()),
              itemBuilder: (BuildContext context, int index) {
                return BlocProvider<ExperienceBloc>(
                  bloc: ExperienceBloc(_experiences[index]),
                  child: ExperienceView(experience: _experiences[index]),
                );
              },
              controller: _swiperController,
              index: snapshot.data.currentIndex,
              indicatorLayout: PageIndicatorLayout.COLOR,
              autoplay: false,
              itemCount: _experiences.length,
              control: (_experiences.length==1)?null:SwiperControl(color: Colors.white),
              pagination: (_experiences.length==1)?null:SwiperPagination(builder: SwiperPagination.fraction),
              onIndexChanged: (index) {
                experiencesBloc.experienceIndex.add(index);
              },
            );
          }
        });
  }

}
