import { test } from 'node:test';
import assert from 'node:assert/strict';
import { addTask, completeTask, deleteTask } from '../src/tasks.mjs';

test('addTask appends an open task', () => {
  const tasks = addTask([], 'buy milk');
  assert.deepEqual(tasks, [{ id: 1, title: 'buy milk', done: false }]);
});

test('addTask rejects an empty title', () => {
  assert.throws(() => addTask([], '  '), /title required/);
});

test('completeTask marks one task done', () => {
  const tasks = completeTask(addTask([], 'a'), 1);
  assert.equal(tasks[0].done, true);
});

test('deleteTask removes the task', () => {
  assert.deepEqual(deleteTask(addTask([], 'a'), 1), []);
});
