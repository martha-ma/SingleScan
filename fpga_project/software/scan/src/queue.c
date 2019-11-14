/******************************************************************************************
 * @file    queue.c
 * @author  kdurant
 * @version V1.0.0
 * @date    7/23/2014
 * @brief   Implementation for a queue. Data is inserted at back and removed from the
 *          front. The queue structure stores a pointer to an array that holds the data and
 *          the size of the array. This allows for different sizes of queues.
 *
 *****************************************************************************************/
#include <stdint.h>
#include "queue.h"

/* queue_init *************************************************************************//**
 * @brief   Initializes a queue. The size of the queue must be a power of two.
 * @param   Queue* const queue: pointer to a Queue.
 * @param   queue_element_t* const ptr: pointer to the array to store the data.
 * @param   const unsigned size: the size of the queue.
 * @return  None
 */
void queue_init(Queue* const queue, queue_item_t* const ptr, const unsigned size)
{
    queue->front = 0;
    queue->rear = 0;
    queue->depth = size;
    queue->data = ptr;
    memset(queue->data, 0, sizeof(queue_item_t) * queue->depth);
    queue->frame_over_flag = 0;
}


/* queue_clear ************************************************************************//**
 * @brief   Sets the front and the back to the same index and flags the queue as empty.
 * @param   Queue* const queue: pointer to a Queue.
 * @return  Queue_Status: returns the status of the queue. Should read Queue_Empty.
 */
void queue_clear(Queue* const queue)
{
    /* Perform the same operation as queue_init(). */
    queue->front = queue->rear = 0;
//    memset(queue->data, 0, sizeof(queue_item_t) * queue->depth);
}


/* enqueue ****************************************************************************//**
 * @brief   Places an entry onto the queue.
 * @param   Queue* const queue: pointer to a Queue.
 *          queue_element_t queue_element: data to be emplaced upon the queue.
 * @return  None.
 */
bool queue_push(Queue* const queue, const queue_item_t queue_element)
{
	queue->data[queue->rear] = queue_element;
	queue->rear = (queue->rear+1) % queue->depth;
    return true;
}


/* dequeue ****************************************************************************//**
 * @brief   Removes an entry from the queue.
 * @param   Queue* const queue: pointer to a Queue.
 * @return  queue_element_t: the last element in the queue.
 */
queue_item_t queue_pop(Queue* const queue)
{
    /* First check to see if the queue is full. Since enqueue() doesn't update the front
     * pointer there is a possibility that the queue could've wrapped. Performing the
     * overfull check here means that 'front' is read only and not write. */
    queue_item_t data = queue->data[queue->front];
    queue->front = (queue->front + 1) % queue->depth;
    return data;
}


/* queue_count ************************************************************************//**
 * @brief   Returns the number of objects in a queue.
 * @param   const Queue *queue: the queue to be checked.
 * @return  unsigned int: count
 */
unsigned int queue_count(const Queue* const queue)
{
    if(queue_is_empty(queue) == false)
        return (queue->rear + queue->depth - queue->front) % queue->depth;
    else
        return 0;
}


/* queue_is_full **********************************************************************//**
 * @brief   Boolean check to see if the queue is full
 * @param   const Queue *queue: the queue to be checked.
 * @return  bool: false if not full. true if full.
 */
bool queue_is_full(const Queue* const queue)
{
    if(queue->front == ( (queue->rear+1) % queue->depth) )
        return true;
    else
        return false;
}


/* queue_is_empty *********************************************************************//**
 * @brief   Boolean check to see if the queue is empty.
 * @param   const Queue *queue: the queue to be checked.
 * @return  bool: false if not empty. true if empty.
 */
bool queue_is_empty(const Queue* const queue)
{
    if(queue->front == queue->rear)
        return true;
    else
        return false;
}

/************************************** END OF FILE **************************************/
