import { SuiObjectResponse } from "@mysten/sui/client";
import { getHero } from "../helpers/getHero";
import { Hero, parseHeroContent } from "../helpers/parseHeroContent";
import { ENV } from "../env";
import { getHeroSwordIds } from "../helpers/getHeroSwordIds";

const HERO_OBJECT_ID =
  "0x26cc4e8173393efa8411b376c17420dc59e48ee6649a634cfaee98477efe5435";

describe("Get Hero", () => {
  let objectResponse: SuiObjectResponse;

  beforeAll(async () => {
    objectResponse = await getHero(HERO_OBJECT_ID);
  });

  test("Hero Exists", () => {
    expect(objectResponse.data).toBeDefined();
    expect(objectResponse.data!.objectId).toBe(HERO_OBJECT_ID);
    expect(objectResponse.data!.type).toBe(`${ENV.PACKAGE_ID}::hero::Hero`);
  });

  test("Hero Content", () => {
    const hero: Hero = parseHeroContent(objectResponse);
    expect(hero.id).toBe(HERO_OBJECT_ID);
    expect(hero.stamina).toBeDefined();
    expect(hero.health).toBeDefined();
  });

  test("Hero Has Attached Swords", async () => {
    const swordIds = await getHeroSwordIds(objectResponse.data!.objectId);
    expect(swordIds.length).toBeGreaterThan(0);
  });
});
