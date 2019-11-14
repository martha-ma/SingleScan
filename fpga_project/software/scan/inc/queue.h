/******************************************************************************************
 * @file	queue.h
 * @author  kdurant
 * @version V1.0.0
 * @date	4/16/2014
 * @brief	Public structures and functions for a queue.
 *
 *****************************************************************************************/
#ifndef QUEUE_H
#define QUEUE_H

#include <stdbool.h>
#include <stdbool.h>
#include <string.h>

/* Public Type Declarations ------------------------------------------------------------ */
typedef unsigned int queue_item_t;

/* Main queue structure */
/*
 * insert data back, delet data front
 */
typedef struct Queue {
	unsigned front;
	unsigned rear;
	unsigned depth;
	unsigned frame_over_flag;
	queue_item_t *data;
} Queue;

/* Public Function Prototypes ---------------------------------------------------------- */
void queue_init(Queue* const, queue_item_t* const, unsigned);
void queue_clear(Queue* const);
bool queue_push(Queue* const, const queue_item_t);
queue_item_t queue_pop(Queue* const queue);
unsigned int queue_count(const Queue* const);
bool queue_is_full(const Queue* const);
bool queue_is_empty(const Queue* const queue);

#endif
/************************************** END OF FILE **************************************/
