#ifndef __dbg_h__
#define __dbg_h__


#include <stdio.h>
#include <errno.h>
#include <string.h>

#ifdef NDEBUG
// ���±���ʱɾ�����е�debug��Ϣ
#define debug(M, ...)
#else
/*
��debug("format string", arg1,arg2,...)ת��Ϊ��stderr�ϵ������__FILE__����
��ǰ����ʹ�õ��ļ���__LINE__�����ļ��ĵ�ǰ�У�__func__��ʾ��ǰ���ں�����
##__VA_ARGS__��ʾdebug(M, ...)�еġ�...���������
 */
#define debug(M, ...) fprintf(stderr, "DEBUG %s:%d: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#endif

// strerror�������Ĵ�����Ϣ���� 
#define clean_errno() (errno == 0? "None": strerror(errno))

// log_err, log_warn, log_info������������debug��M, ...)
#define log_err(M, ...) fprintf(stderr, "[ERROR] (%s:%d:%s errno: %s)" M "\n", __FILE__, __LINE__, __func__,  clean_errno(), ##__VA_ARGS__)

#define log_warn(M, ...) fprintf(stderr, "[WARN] (%s:%d:%s errno: %s) " M "\n", __FILE__, __LINE__, __func__, clean_errno(), ##__VA_ARGS__)

#define log_info(M, ...) fprintf(stderr, "[INFO] (%s:%d:%s) " M "\n", __FILE__, __LINE__, __func__, ##__VA_ARGS__) 

#define check(A, M, ...) if(!(A)) { log_err(M, ##__VA_ARGS__); errno=0; goto error; } 

// ��������Ԥ�ڲ�Ӧ�÷��������
#define sentinel(M, ...)  { log_err(M, ##__VA_ARGS__); errno=0; goto error; } 
// ���ָ�����Ч��
#define check_mem(A) check((A), "Out of memory.")

#define check_debug(A, M, ...) if(!(A)) { debug(M, ##__VA_ARGS__); errno=0; goto error; } 

#endif


