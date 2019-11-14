#ifndef TIM561_H
#define TIME561_H
#include <string.h>

#define SOCKET0     0
#define SOCKET1     1
#define SOCKET2     2
#define SOCKET3     3
#define SOCKET4     4
#define SOCKET5     5
#define SOCKET6     6
#define SOCKET7     7

extern unsigned char udp_reponse[];
extern char *tim561_index[];

extern char *tim561_respons[];
extern char *sMI_2[];
extern char *sMI_0_3_F4724744_stop[];
extern char *sMI_0_3_F4724744_start[];
extern char *sRI_E6_reply[];
extern char sRI_15B_reply[];
extern char sRI_1DC_reply[];
extern char *sMI_reply[];
int find_index_old(char * str, char ** array, int length);
#endif // !TIM561_H

