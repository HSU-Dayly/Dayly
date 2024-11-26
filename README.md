# Dayly
- **FEAT** : 새로운 기능의 추가<br>
- **FIX**: 버그 수정<br>
- **DOCS**: 문서 수정<br>
- **STYLE**: 스타일 관련 기능(코드 포맷팅, 세미콜론 누락, 코드 자체의 변경이 없는 경우)<br>
- **REFACTOR**: 코드 리펙토링<br>
- **TEST**: 테스트 코트, 리펙토링 테스트 코드 추가<br>
- **CHORE**: 빌드 업무 수정, 패키지 매니저 수정(ex .gitignore 수정 같은 경우)<br><br>

ex) git commit -m "fix : 스크롤 버그 수정"<br>
ex) git commit -m "feat : 일기 피드백 기능 추가"

# 📓 Dayly
**사용자의 일상을 기록하고 영어 능력을 향상시키는 일기장 어플: Dayly**
<br> <br>
## 🖥️ 프로젝트 소개
Dayly는 영어로 일기를 쓰면서 자연스럽게 영어 실력을 키울 수 있는 정말 유용한 도구예요. 일기를 쓰다 보면 문법이나 표현이 헷갈릴 때가 있는데, Dayly가 그 순간순간을 도와줘요. 실시간으로 문법 오류나 어색한 표현을 바로잡아줘서, 내가 쓴 영어가 점점 더 자연스러워지죠. 그리고 모르는 단어나 표현이 나오면 바로 번역 기능을 통해 쉽게 뜻을 알 수 있고, 중요한 단어는 개인 단어장에 저장해두고 반복해서 학습할 수 있어요.

그냥 영어 실력만 키우는 게 아니라, 일기 쓰면서 나 자신을 돌아볼 수 있는 기회도 돼요. 일상을 기록하면서 내 생각과 감정을 더 잘 이해하게 되고, 더 나아가 자기 성장을 도와주는 느낌이에요. 영어를 배우면서도 내 삶을 더 깊이 있게 되돌아볼 수 있다는 점에서 이 앱은 정말 매력적인 것 같아요.

Dayly는 그냥 영어 학습 도구가 아니라, 일상적인 자기 성찰을 돕고, 꾸준히 영어 실력을 향상시킬 수 있는 앱이에요. 
한 번 써보면 계속 쓰게 될 거예요!

<br>

## 🕰️ 개발 기간
* 24.11.01 - 24.12.06 (5주)
<br>

## 🧑‍🤝‍🧑 맴버구성
 - 팀원1 : [하여린](https://github.com/niroey) - 웹 서버 구현 및 데이터베이스 구축
 - 팀원2 : [전아린](https://github.com/flsrinn) - Electron 프레임워크를 활용한 터치 스크린 구현
 - 팀원3 : [김은비](https://github.com/ssilverrain) - RaspberryPi를 이용한 AI 소프트웨어 개발 및 테스팅
 - 팀원4 : [정세연](https://github.com/mvg01) - RaspberryPi를 이용한 AI 소프트웨어 개발 및 테스팅
<br>

 ## ⚙️ 개발 환경
- **Programming Language** : Dart
- **IDE** : Visual Studio, Android Studio
- **Framework** : Flutter
- **Database** : Firebase (실시간 데이터베이스, 인증 등 활용)
- **Server**: Firebase Hosting

<br>

## 💝 주요 기능
- Dayly는 번거로운 회원가입 과정 없이 소셜로그인을 통해 사용할 수 있어요. 한 번만 로그인 해도 그 후부터는 자동로그인이 되기 때문에 이용하기에 더 간편해요. 소셜 로그인을 하고, 사용자가 원하는 이름을 정할 수 있어요. 이 이름은 추후에 얼마든지 변경할 수 있어요.
<p align="center"><img src="https://github.com/user-attachments/assets/36271955-aac0-49b9-ad65-6054c6e92714" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/27f25f0f-975b-454f-8fc3-823f49f75517" width="200"/></p>

- 로그인에 성공하면 달력이 나오고, 사용자는 작성한 일기를 달력 또는 표 형태로 확인할 수 있어요.

<p align="center"><img src="https://github.com/user-attachments/assets/6a6323d7-5822-4c79-a0c6-bb262f7e0195" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/bfd9c6a0-1ef2-483e-a87d-58709e6e8d58" width="200"/></p>

- 일기 작성 화면이에요. 오늘 있었던 일을 자유롭게 한글로 먼저 작성할 수 있어요. 모르는 단어가 있더라도 걱정하지 마세요. 아래 쪽의 검색버튼을 이용해 NAVER사전으로 바로 연결시켜드려요. <br> 오른쪽으로 화면을 스와이프 하면 작성한 일기를 영어로 작성해볼 수 있어요. 한번 더 오른쪽으로 스와이프 하면 영어로 작성한 일기를 분석하여 첨삭~~~
<p align="center"><img src="https://github.com/user-attachments/assets/8983f3c8-ded8-48a9-8f61-f42f03983e4a" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/fc0e60f0-aec1-414d-9fb5-d0fb3db10244" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/bc7d7ffa-89b1-4559-9504-e36a2fffdd7d" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/dad5e223-e28c-4c5c-ab0a-880645b25543" width="200"/></p>


- 틀린 부분을 다시 보고 싶을 때도 걱정하지 마세요. 첨삭된 부분 중 중요한 단어를 골라서 나만의 단어장을 만들어줘요. 

<p align="center"><img src="https://github.com/user-attachments/assets/d3606ad3-5fc0-49c7-86c9-bbe2854ac0ce" width="200"/></p>

- 더욱 더 풍부한 영어 공부를 위해, 영작 연습을 도와드려요. Dayly에서 엄선한 문장들 중 하루에 10개를 골라내어서~~~~ 영작연습도 가능~~~

<p align="center"><img src="https://github.com/user-attachments/assets/b2c86c29-0167-41e0-88c1-bfe6a0a33489" width="200"/></p>
<p align="center"><img src="https://github.com/user-attachments/assets/d15ec347-5bd2-4600-983a-0d016743eea5" width="200"/></p>


- 마이페이지도 볼수있음요~

<p align="center"><img src="https://github.com/user-attachments/assets/4a463d72-2227-4cfd-92e7-41f9dd2afbee" width="200"/></p>

<br>

## 🚀 시연 영상
- 밑의 사진을 클릭하면 youtube 주소로 이동합니다.
[![My YouTube Video Thumbnail](https://github.com/HSU-REPLAY/Ecosmetic-Bin/assets/121416032/ddec290b-4381-4ff5-ae10-004aca85c43c)](https://www.youtube.com/watch?v=CitKeV7mHRE)


<br>

## 📈 향후 발전 가능성 및 기대 효과
- 현재 영어를 중심으로 제공되는 기능을 다른 언어로 확장할 수 있습니다. 사용자는 다양한 언어로 일기를 작성하고, 그 언어에 맞춘 AI 피드백을 받아 실시간으로 개선할 수 있게 됩니다. 이는 다국적 사용자층을 형성하고, 언어 학습의 범위를 넓힐 수 있는 기회를 제공합니다.

- AI는 사용자의 일기 작성 패턴을 분석하여 맞춤형 피드백을 제공할 수 있습니다. 예를 들어, 사용자가 반복적으로 틀리는 문법이나 표현을 AI가 자동으로 인식해 주거나, 개인의 학습 수준에 맞춘 고급 영어 표현을 추천하는 등의 기능을 추가할 수 있습니다. 이를 통해 점진적이고 체계적인 언어 능력 향상이 가능합니다.

- 글 뿐만 아니라 음성으로도 일기를 작성할 수 있는 기능을 추가하면, 말하기 연습과 쓰기 연습을 동시에 할 수 있습니다. 음성 인식 기술을 통해 발음 교정이나 문법 체크가 실시간으로 이루어지며, 영어 회화 능력 향상에도 도움을 줄 수 있습니다.

- 일기를 통해 사용자의 감정이나 심리 상태를 분석하고, 이를 기반으로 긍정적인 피드백이나 동기 부여를 할 수 있는 기능이 추가되면, 언어 학습과 자기 성찰을 동시에 이루어질 수 있습니다. 예를 들어, 감정 분석을 통해 사용자가 우울하거나 스트레스를 받았을 때 적절한 위로 메시지를 제공하거나, 긍정적인 피드백을 통해 더 나은 학습 환경을 만들어줄 수 있습니다.

- 일기 외에도 다양한 영어 학습 콘텐츠(퀴즈, 챌린지, 미션 등)를 통해 사용자가 더욱 재미있고 동기 부여가 되는 방식으로 학습할 수 있습니다. 게임화된 요소를 추가하면 학습의 재미를 높일 수 있고, 지속적인 학습을 유도할 수 있습니다.

- 사용자는 자연스러운 방식으로 영어를 학습할 수 있게 되며, 지속적인 피드백을 통해 실시간으로 실력을 향상시킬 수 있습니다. 문법, 어휘, 표현력 등 다양한 측면에서 고르게 발전할 수 있습니다.
  
- 일기를 쓰면서 자신의 생각과 감정을 돌아볼 수 있기 때문에, 단순한 언어 학습을 넘어 자기 성찰을 통한 개인적인 성장을 촉진할 수 있습니다. 영어 실력뿐만 아니라 감정 관리, 자기 인식 등의 측면에서도 긍정적인 변화를 경험할 수 있습니다.
  
- 학습자가 스스로 학습 경로를 설정하고 피드백을 받으며 발전할 수 있기 때문에, 자기주도적인 학습 능력이 강화됩니다. AI가 제공하는 맞춤형 피드백은 사용자가 자신의 약점을 인식하고 보완할 수 있도록 돕습니다.


## 📜 라이선스
MIT licence
