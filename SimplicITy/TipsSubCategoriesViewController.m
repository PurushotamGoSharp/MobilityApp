//
//  TipsSubCategoriesViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/10/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsSubCategoriesViewController.h"
#import "TipDetailsViewController.h"
@interface TipsSubCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsSubCategoriesViewController
{
    NSArray *dataArray;
    NSDictionary *detailsDictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
    
    detailsDictionary = @{
                          @"Instant Messaging":
                              @"Instant messaging (IM) is a type of online chat which offers real-time text transmission over the Internet. A LAN messenger operates in a similar way over a local area network. Short messages are typically transmitted bi-directionally between two parties, when each user chooses to complete a thought and select 'send'. Some IM applications can use push technology to provide real-time text, which transmits messages character by character, as they are composed. More advanced instant messaging can add file transfer, clickable hyperlinks, Voice over IP, or video.",
                          
                          @"Voice Over IP":
                              @"Voice over IP (VoIP) is a methodology and group of technologies for the delivery of voice communications and multimedia sessions over Internet Protocol (IP) networks, such as the Internet. Other terms commonly associated with VoIP are IP telephony, Internet telephony, broadband telephony, and broadband phone service. The term Internet telephony specifically refers to the provisioning of communications services (voice, fax, SMS, voice-messaging) over the public Internet, rather than via the public (PSTN). The steps and principles involved in originating VoIP telephone calls are similar to traditional digital telephony and involve signalling, channel setup, digitization of the analog voice signals, and encoding. Instead of being transmitted over a circuit-switched network, however, the digital information is packetized, and transmission occurs as IP packets over a packet-switched network. Such transmission entails careful considerations about resource management different from time-division multiplexing (TDM) networks",
                          
                          @"Voice conferencing":
                              @"Videoconferencing (VC) is the conduct of a videoconference (also known as a video conference or video teleconference) by a set of telecommunication technologies which allow two or more locations to communicate by simultaneous two-way video and audio transmissions. It has also been called 'visual collaboration' and is a type of groupware.Videoconferencing differs from videophone calls in that it's designed to serve a conference or multiple locations rather than individuals.[1] It is an intermediate form of video telephony, first used commercially in Germany during the late-1930s and later in the United States during the early 1970s as part of AT&T's development of Picture phone technology",
                         
                          @"Web Conferencing":
                              @"Web conferencing refers to a service that allows conferencing events to be shared with remote locations. These are sometimes referred to as webinars or, for interactive conferences, online workshops. In general, the service is made possible by Internet technologies, particularly on TCP/IP connections. The service allows real-time point-to-point communications as well as multicast communications from one sender to many receivers. It offers data streams of text-based messages, voice and video chat to be shared simultaneously, across geographically dispersed locations. Applications for web conferencing include meetings, training events, lectures, or short presentations from any computer",
                          
                          @"Video Conferencing":
                              @"Videoconferencing (VC) is the conduct of a videoconference (also known as a video conference or video teleconference) by a set of telecommunication technologies which allow two or more locations to communicate by simultaneous two-way video and audio transmissions. It has also been called 'visual collaboration' and is a type of groupware. Videoconferencing differs from videophone calls in that it's designed to serve a conference or multiple locations rather than individuals.[1] It is an intermediate form of video telephony, first used commercially in Germany during the late-1930s and later in the United States during the early 1970s as part of AT&T's development of Picture phone technology",
                          
                        @"Financial Accounting (FI)":
                              @"Provide the right foundation for your accounting and reporting teams. Our financial accounting solution unifies robust financial accounting functionalities to help you manage the complexities of your company's global accounting and reporting requirements – for greater efficiency and transparency across the enterprise.",
                          
                          @"Controlling (CO)":
                              @"Controlling provides you with information for management decision-making. It facilitates coordination, monitoring and optimization of all processes in an organization. This involves recording both the consumption of production factors and the services provided by an organization.As well as documenting actual events, the main task of controlling is planning. You can determine variances by comparing actual data with plan data. These variance calculations enable you to control business flows. Income statements such as, contribution margin accounting, are used to control the cost efficiency of individual areas of an organization, as well as the entire organization.",
                         
                          @"Investment Management (IM)":
                              @"The Investment Management (IM) component provides functions to support the planning, investment, and financing processes for: Capital investments, such as the acquisition of fixed assets as the result of-house production or purchase Investments in research and development Projects that fall primarily under overhead, such as continuing education of employees or establishing new markets Maintenance programs The term investment, therefore, is not limited only to investments you capitalize for bookkeeping or tax purposes. An investment in this context can be any measure that initially causes costs, and that may only generate revenue or provide other benefits after a certain time period has elapsed (for example, plant maintenance projects).",
                          
                          @"Configuration Management":
                              @"Configuration Management (CM) is an Information Technology Infrastructure Library (ITIL) version 2 and an IT Service Management (ITSM) process that tracks all of the individual Configuration Items (CI) in an IT system which may be as simple as a single server, or as complex as the entire IT department. In large organizations a configuration manager may be appointed to oversee and manage the CM process. In ITIL version 3, this process has been renamed as Service Asset and Configuration Management.",
                         
                          @"Change Management":
                              @"Change management is an IT service management discipline. The objective of change management in this context is to ensure that standardized methods and procedures are used for efficient and prompt handling of all changes to control IT infrastructure, in order to minimize the number and impact of any related incidents upon service. Changes in the IT infrastructure may arise reactively in response to problems or externally imposed requirements, e.g. legislative changes, or proactively from seeking improved efficiency and effectiveness or to enable or reflect business initiatives, or from programs, projects or service improvement initiatives. Change Management can ensure standardized methods, processes and procedures which are used for all changes, facilitate efficient and prompt handling of all changes, and maintain the proper balance between the need for change and the potential detrimental impact of changes.",
                          
                          @"Release Management":
                              @"Release Management is the process of managing software releases from development stage to software release. It is a relatively new but rapidly growing discipline within software engineering. As software systems, software development processes, and resources become more distributed, they invariably become more specialized and complex. Furthermore, software products (especially web applications) are typically in an ongoing cycle of development, testing, and release. Add to this an evolution and growing complexity of the platforms on which these systems run, and it becomes clear there are a lot of moving pieces that must fit together seamlessly to guarantee the success and long-term value of a product or project. The need therefore exists for dedicated resources to oversee the integration and flow of development, testing, deployment, and support of these systems. Although project managers have done this in the past, they generally are more concerned with high-level, 'grand design' aspects of a project or application, and so often do not have time to oversee some of the more technical or day-to-day aspects. Release managers (aka 'RMs') address this need. They must have a general knowledge of every aspect of the software development process, various applicable operating systems and software application or platforms, as well as various business functions and perspectives.",
                          
                          @"Incident Management":
                              @"Incident Management (IcM) is an IT service management (ITSM) process area. The first goal of the incident management process is to restore a normal service operation as quickly as possible and to minimize the impact on business operations, thus ensuring that the best possible levels of service quality and availability are maintained. 'Normal service operation' is defined here as service operation within service-level agreement (SLA). It is one process area within the broader ITIL and ISO 20000 environment.",
                          

                          @"Workspace Management":
                              @"AirWatch® Workspace Management provides complete separation of corporate and personal data on devices, securing corporate resources and maintaining employee privacy. AirWatch enables organizations to standardize enterprise security and data loss prevention strategies across mobile devices through our flexible approach to containerization. With app-level and AirWatch Workspace options for containerization, you can deploy corporate containers to fit your enterprise security requirements.",
                          

                          @"Mobile Security":
                              @"Security is at the core of AirWatch® Enterprise Mobility Management. AirWatch Mobile Security Management ensures your enterprise mobility deployment is secure and corporate information is protected with end-to-end security extending to users, devices, applications, content, data, email and networks. AirWatch provides real-time device details and continuous compliance monitoring to ensure your devices and corporate data are secure.",
                          

                          @"Mobile Device Management":
                              @"AirWatch® Mobile Device Management enables businesses to address challenges associated with mobility by providing a simplified, efficient way to view and manage all devices from the central admin console. Our solution enables you to enroll devices in your enterprise environment quickly, configure and update device settings over-the-air, and secure mobile devices. With AirWatch, you can manage a diverse fleet of Android, Apple iOS,BlackBerry, Mac OS, Symbian, Windows Mobile, Windows PC/RT and Windows Phone devices from a single management console",
                          

                          @"Mobile Application Management":
                              @"AirWatch® Mobile Application Management addresses the challenge of acquiring, distributing, securing and tracking mobile applications. Easily manage internal, public and purchased apps across employee-owned, corporate-owned and shared devices from one central console.",
                          

                          @"Mobile Content Management":
                              @"AirWatch by VMware enables secure mobile access to content anytime, anywhere. AirWatch® Secure Content Locker® protects your sensitive content in a corporate container and provides users with a central application to securely access, store, update and distribute the latest documents from their mobile devices.",
                          

                          @"Mobile Email Management":
                              @"AirWatch® Mobile Email Management delivers comprehensive security for corporate email infrastructures. Email security requirements vary for organizations, depending on supported device ownership models and industry regulations. AirWatch offers flexible options for your email management strategy, giving you choice over the deployment strategy that best fits your business and security requirements. Integration with existing email infrastructures ensures you are maximizing your technology investments. Access to corporate email can be configured through the native device client or the AirWatch Inbox, a containerized email solution.",
                          };
   
//    fileNames = @[@"Lync_Video", @"WebEx_Video", @"AirWatch_Video"];
//    categoresForVideo = @[@"Lync", @"WebEx", @"AirWatch"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subCategoriesData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *) [cell viewWithTag:100];
//    label.text = [self.parentCategory stringByAppendingFormat:@"-Subcategory %i", indexPath.row+1];
    label.text = self.subCategoriesData[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TipsSubToDetailsSegue"])
    {
        TipDetailsViewController *tipDetailsVC = (TipDetailsViewController *)segue.destinationViewController;
        tipDetailsVC.parentCategory =  self.subCategoriesData[[self.tableView indexPathForSelectedRow].row];
        tipDetailsVC.index = [self.tableView indexPathForSelectedRow].row;
        tipDetailsVC.textToDisplay = detailsDictionary[tipDetailsVC.parentCategory];
        
        if ([self.parentCategory isEqualToString:@"AirWatch"])
        {
            tipDetailsVC.fileName = @"AirWatch_Video";
        }else if ([self.parentCategory isEqualToString:@"Lync"])
        {
            tipDetailsVC.fileName = @"Lync_Video";
        }else if ([self.parentCategory isEqualToString:@"WebEx"])
        {
            tipDetailsVC.fileName = @"WebEx_Video";
        }
    }
}

@end
