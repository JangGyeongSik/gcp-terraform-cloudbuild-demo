* * *

* * *

What is Cloud Build?
--------------------

Cloud Build는 구축, 테스트, 배포를 위한 CI/CD 플랫폼으로, Server를 사전에 Provisioning 할 필요가 없으며 파이프라인을 생성하여 배포를 자동화합니다.  
Cloud Build를 사용하면 Serverless 환경의 배포 관련 효율성을 높힐수 있습니다.

* * *

Required Permissions and API Enforcement
----------------------------------------

1.  ### Enable APIs
    
    1.  Cloud Function, Cloud Logging, Cloud Storage API
        
    2.  Compute Engine, Cloud Pub/Sub, Cloud Build API
        
2.  ### Service Account Permissions
    
    1.  Compute,Cloud Functions,Pub/Sub Admin
        
    2.  ServiceAccountTokenCreator
        
    3.  Cloud Build Editor
        
    4.  Logs Viewer, Writer
        
    5.  Viewer(Basic)
        

* * *

Cloud Build Configuration
-------------------------

1.  ### As-Is Architecture  
    
2.  ### To-Be Architecture
    
    1.  Packer를 활용하여 Image 생성 후 Instance & Instance Template 생성(1안)  
        
    2.  Packer를 사용하지 않고, Golden Image를 통해 Instance & Instance Template 생성(2안)  
        
3.  ### Options for creating cloud builds
    

  

1.  1.  Event(Trigger) Options
        1.  Repository 기반 Event
            1.  Push to a Branch
                1.  Branch에 Push를 했을 경우
            2.  Push new tag
                1.  새로운 Tag를 붙인 상태에서 Push를 했을 경우
            3.  Pull Request
                1.  해당 Repository(GitHub,Bitbucket,Gitlab)에 PR을 요청했을 때
                2.  **Source Repository에서는 사용 불가능**
        2.  Response 기반 Event
            1.  Manaul Invocation
                1.  Build Trigger를 수동으로 호출하고 싶은 경우
            2.  Pub/Sub Message
                1.  Pub/Sub Message를 이용하여 Trigger를 생성시키고 싶은 경우
            3.  Webhook Event
                1.  WebHook Event 발생시 Trigger를 생성시키고 싶은 경우
    2.  Filter를 통해 Build Trigger의 작동을 묵시할 수 있는 옵션도 glob 형태로 제공
        1.  상기 이미지 참고(Included, Ignored)
2.  ### Git Hub App 연동
    
    1.  Connect Repository
        
    2.  Authenticate → Select Repository  
        1.  GitHub 콘텐츠를 기반으로 GCP Project에서의 권한을 GitHub App에게 허용해주는 옵션
3.  ### Configuration
    
    1.  Type
        
        1.  Autodetected
            
            1.  Repository에서 cloudbuild yaml을 자동으로 찾아주는 옵션
                
        2.  **Cloud Build Configuration File (yaml or json)**
            
            1.  Build Trigger 관련해서 yaml or json을 수동으로 설정  
                
        3.  DockerFile  
            
            1.  DockerFile을 사용하여 Build Image 설정 가능
                
            2.  Trigger가 될 Repository의 DockerFile Direcoty 및 Name 입력
                
            3.  Image Name의 경우, 아래 Variable을 제공
                
                1.  Supported variables
                    
                    1.  $PROJECT\_ID, $REPO\_NAME, $BRANCH\_NAME, $TAG\_NAME, $COMMIT\_SHA, $SHORT\_SHA
                        
            4.  Timeout은 Default는 10분으로 명시 되어있으며, 수정하여 제한시간을 설정 가능 **( max: 86400sec )**  
                
        4.  Buildpacks
            
            1.  Buildpacks도 DockerFile과 유사하나, Builder image 및 환경 변수를 별도로 설정할수 있는 기능이 있습니다.
                
4.  ### Advanced
    
    1.  대체 변수(Substitution variables)
        
        1.  다른 변수값으로 cloudbuild yaml을 재사용할 수 있습니다.
            
        2.  변수에 대한 내용은 첨부 드리는 [링크](https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values?_ga=2.145044212.-1554764575.1670140601)를 참고하시면 될 것 같습니다.
            
    2.  승인(Approval)
        
        1.  Build Trigger가 울렸을때, 허용을 할지 안할지에 대한 절차 관련 옵션입니다.
            
    3.  Build Logs
        
        1.  Build Log는 해당 Repository에 대한 읽기 권한이 있는 모든 GitHub User에게 표시되는 옵션입니다.
            
    4.  Service Account
        
        1.  Trigger를 호출할때 사용할 Service Account를 선택하는 옵션입니다.
            
        2.  Service Account를 선택하지 않을 경우, Default Cloud Build Service Account가 사용됩니다.
            

* * *

Result
------

1.  ### GitHub(Terraform Module & Desginated Directory)  
    
    1.  Private Repo로 작성되었으며, Bitbucket에 별도로 배포하여 공유 드릴예정입니다.
    2.  cloudbuild.yaml
        
2.  ### GitHub Repo에 cloudbuild.yaml Push
    
    1.  Access Approval이 활성화 되어 있어, 아래와 같이 승인 절차 진행
        
    2.  승인 이후 cloudbuild.yaml에 명시한 대로 Terraform Command 진행
        
        1.  Cloud Build Logs
            
        2.  Compute Engine List
            
            1.  Terraform.tfvars를 기준으로 하는 GCE 1대가 배포된 것을 위와 같이 확인 가능
                

* * *

Reference
---------

*   [Cloud Build Overview](https://cloud.google.com/build/docs/overview?hl=ko)
*   [Slack Integration with Cloud Build](https://alonge.medium.com/how-to-setup-slack-integration-for-google-cloud-build-using-cloud-functions-e357b580c7a1)
*   [How to use Terraform with Cloud Build](https://engineering.sada.com/using-google-cloud-build-to-execute-a-terraform-script-7dc818ccecdf)

* * *

**END**
