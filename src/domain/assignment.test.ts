import { describe,expect,it } from 'vitest'; import { members } from '../data/demo'; import { createAssignments,validateAssignments } from './assignment';
describe('기니또 배정',()=>{it('모든 멤버를 정확히 한 번씩 배정하고 본인은 제외한다',()=>{for(let i=0;i<50;i++)expect(validateAssignments(members,createAssignments(members))).toBe(true)});it('두 명 미만은 거부한다',()=>expect(()=>createAssignments([])).toThrow())});
