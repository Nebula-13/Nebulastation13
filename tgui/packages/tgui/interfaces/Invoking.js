import { sortBy } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Section, BlockQuote} from '../components';
import { Window } from '../layouts';

export const Invoking = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    admin,
  } = data;
  const magics = sortBy(magics => magics.name)(data.magics || []);
  return (
    <Window
      width={500}
      height={900}>
      <Window.Content scrollable>
        <Section textAlign="center" title="Invoking Magic">
          <Box>
          Some people have the power to invoke magic through a series of words. Here is a list of spells that can be invoked.
          </Box>
        </Section>
          {data.magics!== null ? (
            magics.map(magia => (
              <Section
                key={magia.name}
                title={magia.name}
                level={2}>
                <Box bold my={1}>
                  {magia.desc}
                </Box>
                <BlockQuote my={1}>
                  {admin ? (<div>
                  Phrase: {magia.phrase} <br /></div>) : null }
                  Complexity: {magia.complexity} <br />
                  Mana cost: {magia.mana} <br />
                  Uses: {magia.uses ? magia.uses : "∞"} <br />
                  Cooldown: {magia.cooldown ? magia.cooldown : "No cooldown"} <br />
                  </BlockQuote>
                {magia.roundstart ? (
                  <Box italic my={1}>
                    this magic can be used roundstart
                </Box>) : null}
              </Section>
            ))
          ) :
            <Section textAlign="center" title="Loading..">
              <Box>
                Wait for initialization to finish.
              </Box>
            </Section>
          }
          <Section textAlign="center" title="">
          <BlockQuote>
            <b>Complexity</b>: The difficulty of the magic, the number of words needed. <br />
            <br /> Most spell phrases are random, but you can search in the maintenance for them, some will be the same all round, that is, they never change, and can always be used at any time. <br />
            <br /><b>Be aware</b>: Using magic excessively will result in a slow death. <br />
            Using magic also accumulates magic residue. If the residue is too high, some bad things can happen to the user. <br />
            <br />If you want to know if you can use spells, use your notes {'(IC tab > Notes)'}. <br />
          </BlockQuote>
          </Section>
      </Window.Content>
    </Window>
  );
};
